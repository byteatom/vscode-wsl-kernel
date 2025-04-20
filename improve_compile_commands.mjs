import Fs from "node:fs";
import Path from "path";
import ChildProcess from "child_process";
import Util from "util";
import Yaml from "yaml";

const dbFile = "compile_commands.json";
const dbStr = Fs.readFileSync(dbFile, { encoding: "utf-8" });
const tuArray = JSON.parse(dbStr);
const orginCount = tuArray.length;
const tuSet = new Set(tuArray.map((tu) => Path.resolve(tu.directory, tu.file)));
for (let i = 0; i < tuArray.length; ++i) {
	console.log(`[${i + 1}/${tuArray.length}] ${tuArray[i].file}`);
	const tu = tuArray[i];
	const tuBaseName = Path.basename(tu.file);
	if (!tuBaseName.endsWith(".c")) {
		continue;
	}
	const cmd = tu.arguments ?? tu.command;
	if (!cmd) {
		console.error(tu.file, ": no command or arguments");
		continue;
	}
	const frontendOptions = cmd.substring(cmd.indexOf(" ") + 1, cmd.lastIndexOf(" "));
	const pptrace = `pp-trace-19 -callbacks InclusionDirective ${tu.file} -- ${frontendOptions}`;
	const { stdout } = await Util.promisify(ChildProcess.exec)(pptrace, {
		cwd: tu.directory,
		maxBuffer: 10 * 1024 * 1024,
	});
	const yaml = Yaml.parse(stdout);
	const headers = [];
	for (const inc of yaml) {
		const locBaseNameLastIndex = inc.HashLoc.indexOf(":");
		if (locBaseNameLastIndex === -1) locBaseNameLastIndex = inc.HashLoc.length;
		const locBaseName = inc.HashLoc.substring(
			inc.HashLoc.lastIndexOf(Path.sep) + 1,
			locBaseNameLastIndex
		);
		if (locBaseName !== tuBaseName) continue;

		if (inc.File.toLowerCase().endsWith(".h")) headers.push(inc);
		if (!inc.File.toLowerCase().endsWith(".c")) continue;

		const tuDir = Path.resolve(tu.directory, Path.dirname(tu.file));
		const incSrc = inc;
		const newTuFile = Path.resolve(tuDir, incSrc.File);
		if (tuSet.has(newTuFile)) {
			continue;
		} else {
			tuSet.add(newTuFile);
			console.log("   #include:" + newTuFile);
		}
		let newCmd = cmd.substring(0, cmd.lastIndexOf(" "));
		newCmd += headers.reduce((acc, header) => {
			const newHeaderPath = header.IsAngled
				? header.FileName
				: Path.relative(tu.directory, Path.resolve(tuDir, header.File));
			return `${acc} -include '${newHeaderPath}'`;
		}, "");
		newCmd += ` '${Path.relative(tu.directory, newTuFile)}'`;
		const newTu = {
			command: newCmd,
			directory: tu.directory,
			file: newTuFile,
		};
		tuArray.splice(i + 1, 0, newTu);
		i++;
	}
}
if (tuArray.length !== orginCount) {
	Fs.writeFileSync(dbFile, JSON.stringify(tuArray, null, 2), { encoding: "utf-8" });
}
