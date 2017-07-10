Chapter 00: Introduction
=======================

This tutorial will lead you through the process of installing and configuring a test installation of the ICAT software.

Aim
---

The aim of this tutorial is to give the reader a introduction to the ICAT software and the process of installing and configuring it. The result of following this tutorial will be a system with enough of the ICAT components installed to allow the user to test the functionality of the software. It is important to note that the resulting system will not be fault-tolerant or secure enough to use in a production environment. It should, however, be sufficient to allow the user to load some data and interact with it to understand how the components relate to one another.

Before You Start
----------------

This tutorial assumes that you have access to a system (or virtual machine) with a RedHat-derived version of GNU/Linux installed, such as CentOS, and that you are familiar with system administration on this type of operating system. This tutorial was tested on a minimal installation of CentOS version 6.6. If you are unsure which software to use to create a virtual machine, several ICAT developers have had success with the combination of VirtualBox and Vagrant. See the next optional chapter for instruction on how to do this.

Software Versions
-----------------

At the time of writing this tutorial, the current stable version of the ICAT Server - the main component of the ICAT software - is 4.8.0. This will be the version installed in this tutorial along with its dependencies. The full list of software and components installed in this tutorial are listed below:

OpenJDK Java 1.8.0
GlassFish 4.0
MySQL 5.1
Simple Authenticator [1.1.0](https://repo.icatproject.org/site/authn/simple/1.1.0/)
ICAT Server [4.8.0](https://repo.icatproject.org/site/icat/server/4.8.0/)
IDS Storage File plugin [1.3.3](https://repo.icatproject.org/site/ids/storage_file/1.3.3/)
ICAT Data Server (IDS) [1.7.0](https://repo.icatproject.org/site/ids/server/1.7.0/)
TopCat [2.2.1](https://repo.icatproject.org/site/topcat/2.2.1/)