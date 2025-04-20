# VSCODE-WSL-KERNEL

Browse linux kernel source code resident in WSL with VSCODE and clangd.

# Why This Project

There are many tutorials about browsing linux kernel code using vscode, but there is a problem, when a .c file included by another .c file, this file will not appear in compile_commands.json. When opening this file in vscode, clangd has inferred where the file included, but i don't know why it isn't parsed correctly. Hopefully clangd will be able to support this situation in the future.

This project fix this problem temporary by adding these included .c files into compile_command.json.

# Prerequisites

-   VSCODE
-   WSL2

# Usage

Just clone this project and run:

```shell
./setup.sh kernel_version [clang_suffix]
```

example：

```shell
./setup.sh 6.14.3 -19
```

When successful, the new source code directory is automatically opened using vscode.

When you open the first file in vscode, clangd parses and caches all files.
