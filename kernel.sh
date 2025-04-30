#!/usr/bin/env bash

set -e

cd "$(dirname "$0")"

if [ "$#" -lt 1 ]; then
	echo "Usage: ./kernel.sh kernel_version [clang_suffix]"
	echo "Example: ./kernel.sh 6.14.3 -19"
	exit 1
fi

sudo apt install wget -y
KERNEL_DIR=linux-"$1"
KERNEL_FILE=$KERNEL_DIR.tar.xz
if [ ! -f "$KERNEL_FILE" ]; then
	KERNEL_MAJOR=$(cut -d '.' -f 1 <<<"$1")
	wget https://mirrors.edge.kernel.org/pub/linux/kernel/v"$KERNEL_MAJOR".x/"$KERNEL_FILE"
fi
if [ ! -d "$KERNEL_DIR" ]; then
	tar -xf "$KERNEL_FILE"
fi

cd "$KERNEL_DIR" || exit 1

CLANG_SUFFIX="${2}"
CLANG=clang${CLANG_SUFFIX}
CLANGTOOLS=clang-tools${CLANG_SUFFIX}
CLANGD=clangd${CLANG_SUFFIX}
sudo apt install build-essential libncurses-dev bison flex libssl-dev libelf-dev bc python3 "${CLANG}" "${CLANGD}" "${CLANGTOOLS}" -y
make CC="${CLANG}" menuconfig
make CC="${CLANG}" -j8
python3 scripts/clang-tools/gen_compile_commands.py

if ! command -v node &>/dev/null; then
	sudo apt install curl unzip -y
	curl -o- https://fnm.vercel.app/install | bash
	fnm install 22
fi
npm install yaml
node ../improve_compile_commands.mjs

cp -r ../.vscode-kernel .vscode
sed -i "s/\"clangd\"/\"${CLANGD}\"/" .vscode/settings.json
code --install-extension llvm-vs-code-extensions.vscode-clangd
code .
