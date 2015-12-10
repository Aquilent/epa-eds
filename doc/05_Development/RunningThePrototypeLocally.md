# Introduction
This page describes how to download and run the Drug Reaction Finder (previously known as the drug-adverse-event-browser) on your local machine using Vagrant and Oracle VirtualBox

# Description
Vagrant is a tool that can be used to provision virtual machines via a Ruby configuration file. It can provision VirtualBox, VMWare and AWS virtual machine. Vagrant makes it extremely simple to create, configure destroy, and recreate virtual machines. Vagrant configuration includes network settings and mounting of local directories to the VM. All of this configuration is handled via the configuration text file, the Vagrantfile. Using a text file enables versioning and sharing of your VM configuration.

# Prerequisites
1. Download and install VirtualBox from https://www.virtualbox.org/wiki/Downloads
2. Download and install Vagrant from http://www.vagrantup.com/downloads.html
3. Download and install Git for Windows (for its ssh implementation) from http://git-scm.com/download/win

# Caveats
When using a virtual machine, or virtual workspace (such as AWS Workspaces) to run VirtualBox this may not work, as some virtualization software can block or prevent further (nested) virtualization. Sometimes you need to downscale the architecture from 64-bits to 32-bits, when running in a 64-bit virtual environment. See instructions below how to down-scale.

# Note
The prototype is called the Drug Reaction Finder (DRF).  The original name of the prototype was the Drug Adverse Event Browser, and thus, the repository is called the drug-adverse-event-browser.  This is consistent in the installation instructions below. 

# Installation
Take the following steps to setup for running the Drug Reaction Finder in a virtual machine on Windows:

1. Create The Project Home directory, e.g. `C:\Project\DRF`. You will install the project code into this directory
2. Create a `bin` subdirectory in the Project Home directory, e.g. `C:\Project\DRF\bin`
3. Create a `branches` subdirectory in the Project Home directory, e.g. `C:\Project\DRF\branches`
4. Download the master branch from https://github.com/Aquilent/drug-adverse-event-browser by using clicking "Download ZIP" and saving the file locally.
5. Extract the `drug-adverse-event-browser-master.zip` file to the newly created branches directory, e.g. `C:\Project\DRF\branches\drug-adverse-event-browser-master`.
6. Rename the branch directory from `drug-adverse-event-browser-master` to `master`
7. Create a file `drf.cmd` in the Project Home bin directory (e.g. `C:\Project\DRF\bin\drf.cmd`) with the following contents:
    ```
    @echo off
    
    set PROJECT_HOME=/path/to/drb/installation/directory
    REM e.g. set PROJECT_HOME=C:\Project\DRF
    set PROJECT_NAME=DRF
    
    set GIT_HOME=/path/to/git/installation/directory
    REM e.g. set GIT_HOME=C:\Program Files (x86)\git
    set VAGRANT_HOME=/path/to/vagrant/installation/directory
    REM e.g. set VAGRANT_HOME=C:\Programs Files (x86)\Vagrant
    
    set PATH=%PATH%;%GIT_HOME:/=\%\bin;;%VAGRANT_HOME:/=\%\bin
    
    set BRANCH_NAME=master
    set BRANCH_HOME=%PROJECT_HOME%\branches\%BRANCH_NAME%
    
    REM Uncomment the following line if you are using a Virtual workspace, such a AWS Workspaces
    REM set DEFAULT_VAGRANT_BOX=chef/centos-6.6-i386
    
    echo Change directory to %BRANCH_HOME%
    C:
    cd %BRANCH_HOME%\bin
    
    vagrant-up default
    ```
8. Make sure you set the environment variables in the script to the appropriate paths.  For example, in the script, make sure you set PROJECT_HOME to the location you created in step 1 above.
9. Run the newly created script. This will bring up your virtual machine, and setup all the necessary software on that virtual machine, as well as the application.

9. Once the script finishes it will show the following (or similar) output:

    ```
    ==> app: sebastian/global-state suggests installing ext-uopz (*)
    ==> app: phpunit/phpunit-mock-objects suggests installing ext-soap (*)
    ==> app: phpunit/php-code-coverage suggests installing ext-xdebug (>=2.2.1)
    ==> app: phpunit/phpunit suggests installing phpunit/php-invoker (~1.1)
    ==> app: Generating autoload files
    ==> app: Generating optimized class loader
    ==> app: Compiling common classes
    ==> app: /home/vagrant
    ==> app: Done
    ```
The last line **`==> app: Done`** is the key line. "app" is the name by which Vagrant provisions the virtual machine.  You may run into a situation where the process does not seem to end, and you keep seeing the line **`app: Warning: Connection timeout. Retrying...`**.  In this case, you probably are running into the nested virtualization issue:
    ```
    ==> app: Booting VM...
    ==> app: Waiting for machine to boot. This may take a few minutes...
        app: SSH address: 127.0.0.1:2222
        app: SSH username: vagrant
        app: SSH auth method: private key
        app: Warning: Connection timeout. Retrying...
        app: Warning: Connection timeout. Retrying...
        app: Warning: Connection timeout. Retrying...
        app: Warning: Connection timeout. Retrying...
        app: Warning: Connection timeout. Retrying...
        app: Warning: Connection timeout. Retrying...
        app: Warning: Connection timeout. Retrying...
        app: Warning: Connection timeout. Retrying...
        app: Warning: Connection timeout. Retrying...
    ```
If that happens, you should uncomment the line
    ```
    REM set DEFAULT_VAGRANT_BOX=chef/centos-6.6-i386
    ```
in the `drf.cmd` script by removing the word `REM`. Note that it is normal to see the line **`app: Warning: Connection timeout. Retrying...`** at least several times, while Vagrant waits for the VirtualBox VM to complete booting. How many times, depends on the configuration of your computer, how much work the computer is currently doing, etc.
10. Open a browser and browse to http://192.168.11.12 and you should see and be able to use the application.  Congratulations!

# Use For Development

The local environment is used by developers to verify changes to the web application. In order to do this, a developers uses `git clone` to pull the source code from the repository into a `branches` subdirectory in the Project Home directory for the relevant branch (typically the integration branch), e.g. `C:\Project\DRF\branches\integration` This replaces step 3 through 6 in the above description.

Once a developer has run the Vagrant/Chef provisioning of the virtual machine, the developer can make changes to the application source code and test the changes immediately in the locally hosted application. In some limited cases, the virtual machine has to be reprovisioned, using `vagrant provision` to reprovision the local virtual machine. Once the developer completes testing the changes, the developer commits those changes to the integration branch. 
