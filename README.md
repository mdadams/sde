Software Development Environment (SDE)
======================================

This repository contains tools for managing a software development
environment used for teaching C++/C.

Installing the SDE
==================

In what follows, let $INSTALL_DIR denote a new (nonexistent) directory in
which to install the SDE; and let $REPO_DIR denote a new (nonexistent)
directory in which to clone the SDE repository.

To install the SDE, perform the following steps (in order):

1) Clone the Git repository for the SDE with the command:

    git clone https://github.com/mdadams/sde.git $REPO_DIR

2) Run the SDE installer with the command:

    $REPO_DIR/installer -d $INSTALL_DIR

This step will download, build, and install all of the software
that is part of the SDE.
