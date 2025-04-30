#!/usr/bin/env bash

set -e

cd "$(dirname "$0")"

if [ "$#" -lt 1 ]; then
	echo "Usage: ./glibc.sh glibc_version [clangd_suffix]"
	echo "Example: ./glibc.sh 2.41 -19"
	exit 1
fi

sudo apt install wget -y
GLIBC_DIR=glibc-"$1"
GLIBC_FILE=$GLIBC_DIR.tar.xz
if [ ! -f "$KERNEL_FILE" ]; then
	wget https://mirrors.nju.edu.cn/gnu/glibc/"$GLIBC_FILE"
fi
if [ ! -d "$GLIBC_DIR" ]; then
	tar -xf "$GLIBC_FILE"
fi

cd "$GLIBC_DIR" || exit 1

CLANGD=clangd${CLANG_SUFFIX}
sudo apt install build-essential gdb bison python3 python3-pexpect bear "${CLANGD}" -y
if [ -d build ]; then
	rm -rf build
fi
mkdir -p build
cd build
../configure --prefix="$(pwd)/../install"
bear -- make -j8
make install

cd ..
cp -r ../.vscode-glibc .vscode
sed -i "s/\"clangd\"/\"${CLANGD}\"/" .vscode/settings.json
code --install-extension llvm-vs-code-extensions.vscode-clangd
code .
