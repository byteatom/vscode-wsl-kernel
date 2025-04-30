# VSCODE-WSL-KERNEL

Browse linux kernel source code resident in WSL with VSCODE and clangd.

# Why This Project

There are many tutorials about browsing linux kernel code using vscode, but there is a problem, when some .c file included by another .c file to speed up compilation, such as deadline.c rt.c and idle.c included by build_policy.c, these file usually are not self-contained, and will not appear in compile_commands.json. Clangd has inferred where these file included, but has not parsed them correctly because they are not self-contained. There is a [issue](https://github.com/clangd/clangd/issues/45) about this situation keep open since 2019.

This project fix this problem by adding these included .c files into compile_command.json with proper compiler options.

# Prerequisites

-   VSCODE
-   WSL2

# Usage

Just clone this project and run:

```shell
./kernel.sh kernel_version [clang_suffix]
```

example：

```shell
./kernel.sh 6.14.3 -19
```

When successful, the new source code directory is automatically opened using vscode.

When you open the first file in vscode, clangd parses and caches all files.

# Limit

For source base other than linux kernel there are many situation not handled precisely, including but not limited to:

-   .cpp
-   macro defined before where .c included in including file
