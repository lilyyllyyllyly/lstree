Lists specified directories recursively with a tree view, similar to [tree(1)](https://linux.die.net/man/1/tree). <br>
I made this mostly to learn common lisp, since tree already does this faster and better.

# Installation and Usage
## Installing dependencies
To use lstree, you will need Clozure CL (other common lisp implementations may not work due to the use of the directory function) and git.

To install Clozure CL, either [grab the latest github release](https://github.com/Clozure/ccl/releases/latest) or use your distribution's package manager if it's available there.

If you dont already have it, git is in most distribution's package managers, for example (run these as root):

Ubuntu based:
```
apt install git
```

Arch based:
```
pacman -S git
```

Fedora:
```
dnf install git
```

## Running the Program
First, you need to clone the github repository:

```bash
$ git clone https://github.com/lilyyllyyllyly/lstree
$ cd lstree
```

From here you have two options: create an application to use from the command line, or using it directly from the REPL.

### Creating Standalone Application (Clozure CL only)
To create an application using Clozure CL, first load the `lstree.cl` file:
```
$ ccl -l lstree.cl
```

And in the REPL run the following function:
```lisp
(save-application "lstree" :toplevel-function #'main :prepend-kernel t)
```

This will quit the REPL and create a binary that can be run directly. <br>
More information about this function can be found in the [Clozure CL Documentation](https://ccl.clozure.com/docs/ccl.html#saving-applications).

See how to use the resulting program in [Command Line Usage](#command-line-usage).

### Using Inside the REPL
The function used to list the contents of a directory is dir-contents. <br>
It's definition is the following:

```lisp
(defun dir-contents (&key (path #P"./") (padding 2) max-depth (follow-links nil) (depth 0)) ...)
```

The keyword parameters are equivalent to the command line options shown in [Command Line Usage](#command-line-usage).

## Command Line Usage
```
Usage: lstree [OPTION...] [DIRECTORY...]
List contents of DIRECTORY(s) recursively, with a tree view.

If no DIRECTORY is specified, lists contents of the current directory.

Long options do not use an equal sign (=). Unrecognized options are treated as paths.
  -h, --help                  show this help page
  -m, --max-depth DEPTH       descend at most DEPTH directories
  -f, --follow-links          follow symbolic or hard links and show their directory contents
  -p, --padding VALUE         separate inner files/directories with VALUE spaces
```
