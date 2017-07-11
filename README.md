# icat_install
This repository contains configuration and scripts for installing [ICAT](http://icatproject.org) in a Vagrant VM and a tutorial to follow to install the software manually.

## Quick Start
1. Clone the repository
2. Change directory to icat__install
3. Type `vagrant up`
4. Type `vagrant ssh` to access your machine.
5. `sudo -i` to become the `root` user then `su glassfish` and `cd` to change to the glassfish account (where the ICAT software is installed).

## Tutorial
- [Introduction](icat_install_tutorial/00Introduction.md)
- [Vagrant Setup](icat_install_tutorial/01VagrantSetup.md)
- [Prerequisites](icat_install_tutorial/02Prerequisites.md)
- [Installing Glassfish](icat_install_tutorial/03InstallingGlassFish.md)
- [Installing Authentication](icat_install_tutorial/04InstallingAuthentication.md)
- [Installing ICAT Server](icat_install_tutorial/05InstallingICATServer.md)
- [Installing a Storage Plugin](icat_install_tutorial/06InstallingStoragePlugin.md)
- [Installing the ICAT Data Service](icat_install_tutorial/07ICATDataService.md)
- [Creating Test Data](icat_install_tutorial/08TestData.md)
- [Installing TopCat](icat_install_tutorial/09TopCat.md)
- [Log in to TopCat](icat_install_tutorial/10LogInToTopCat.md)
- [Next Steps](icat_install_tutorial/11NextSteps.md)
