#!/usr/bin/env bash

set -e

if [ "$#" -lt 1 ]; then
	echo "Usage: ../grepglibc.sh grep_misc"
	echo "Example: ../grepglibc.sh __NR_socket"
	exit 1
fi

sysdeplist=$(sed -nE 's/^\s*config-sysdirs\s*=\s*(.+)$/\1/p' build/config.make | sed -nE 's/\s+/\/* /gp')"/*"

grep --color=always -s -n -d skip --exclude-dir={sysdeps*,build,install,advisories,localedata,manual,ChangeLog.old,po,benchtests,hurd,scripts,sunrpc,nscd,timezone} --exclude='*' --include={'*.c','*.h','*.S','*.list'} --exclude={'*tst*','*test*'} $@ $sysdeplist
