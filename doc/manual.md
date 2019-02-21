Software Development Environment (SDE)
======================================

This document contains information about how to install and use the Software
Development Environment (SDE), a set of tools for managing a simple environment
for C++/C software development.  The SDE has proven quite useful for the
purposes of teaching programming courses that use C++/C at the University
of Victoria.

The SDE includes the following packages:

    * Aristotle
    * Boost
    * Catch2
    * CGAL
    * Clang
    * CMake
    * GCC
    * Gcovr
    * GDB
    * GSL
    * JasPer
    * Lcov
    * libcxx
    * Ndiff
    * SPL
    * TeX Live
    * Vim
    * Vim LSP
    * YouCompleteMe (YCM)

In addition, the SDE contains some scripts for managing the SDE itself.


Installing the SDE
==================

In what follows, let $INSTALL_DIR denote a new (nonexistent) directory
in which to install the SDE; and let $REPO_DIR denote a new (nonexistent)
directory in which to clone the SDE repository.

To install the SDE, perform the following steps (in order):

1) Clone the Git repository for the SDE with the command:

    git clone https://github.com/mdadams/sde.git $REPO_DIR

2) Run the SDE installer with the command:

    $REPO_DIR/installer -d $INSTALL_DIR

This step will download, build, and install all of the software that is part
of the SDE.


Using the SDE: Initialization
=============================

For the remainder of this document, $SDE_TOP_DIR will be used to denote
the top-level directory of the SDE software installation.  (This is the
directory containing a directory called "packages".)  All later occurences
of $SDE_TOP_DIR in this document should be read as if they were replaced by
the top-level directory of the SDE.

In order for the SDE to be used, it must first be initialized.  This can be
accomplished via the sde_shell or sde_make_setup commands as described below.
Of these two commands, sde_shell is simpler to use.

The sde_shell Command
---------------------

The sde_shell command will start a new shell that is initialized to use the
SDE.  In the case of the Bash shell, a modified command prompt is employed by
the new shell in order to make clear that the SDE is being used.  The above
command ensures that various environment variables are set correctly for the
compiler, linker, and/or dynamic linker.  This initialization must be done
correctly or it may not be possible to compile, link, and/or execute programs.

To invoke the sde_shell command, type:

    $SDE_TOP_DIR/bin/sde_shell

The sde_make_setup Command
--------------------------

The sde_make_setup command simply prints (to standard output) the commands
necessary for a particular shell to initialize the SDE.  Currently, this
command only supports the bash and tcsh shells.  Since the sde_make_setup
command only prints the commands required for initialization without causing
them to be executed, it is the responsibility of the user to use the printed
commands appropriately (i.e., by executing them).  How this is done depends
on the particular shell being used.

To invoke the sde_make_setup command, causing it to print the sequence of
commands required for initialization in the case of the shell $shell, where
$shell is either bash or tcsh, type:

    $SDE_TOP_DIR/bin/sde_make_setup -s $shell

Of course, simply running the preceding command does not actually do any
initialization since it only prints commands without causing them to be
executed.

If you use the bash shell, you can run sde_make_setup and cause the commands
output by sde_make_setup to be executed by typing:

    eval `$SDE_TOP_DIR/bin/sde_make_setup -s bash`

Furthermore, by adding the preceding command to your bash_profile file (i.e.,
$HOME/.bash_profile), you can initialize the SDE automatically in each new
bash shell that you start.  (Note that adding the command to your bashrc
file may not work, since, on some systems, the login shell does not read
the bashrc file.)

If you use the tcsh shell, you can run sde_make_setup and cause the commands
output by sde_make_setup to be executed by typing:

    eval `$SDE_TOP_DIR/bin/sde_make_setup -s tcsh`

Furthermore, by adding this command to your tcshrc file (i.e., $HOME/.tcshrc)
or login file (i.e., $HOME/.login), you can initialize the SDE automatically
in each new tcsh shell that you start.


Using the SDE: After Initialization
===================================

After the SDE has been initialized, all of the commands that are part of
the SDE should be on your (command) search path.  The commands that are most
likely to be of interest are as follows:

    g++
    gcc
    clang++
    clang
    cmake
    gdb
    vim
    ctest
    latex
    pdflatex
    imgcmp

Do not change the PATH environment variable, except through the use of the
sde_shell or sde_make_setup commands.

Do not change the LD_LIBRARY_PATH environment variable, except through the
use of the sde_shell or sde_make_setup commands.

Do not add /usr/include to the include search path.

Do not add /lib, /lib64, /usr/lib, /usr/lib64, or other such directories to
the library search path.
