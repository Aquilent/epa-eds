@echo off

set TEST_NAME=%1

if exist ./setenv.cmd (
    call ./setenv.cmd %2 %3 %4 %5 %6 %7 %8 %9 
) else (
    echo No branch-specific configuration found
)


set TEST_HOME=%BRANCH_HOME:/=\%\src\test\chef\%TEST_NAME%

if "%TEST_NAME%" == "" (
	echo Usage: $0 test_name
	echo    where test_name is name of subdirectory in %BRANCH_HOME%
	pause
	exit 1
)

if not exist "%TEST_HOME%" (
	echo Test directory %TEST_NAME% not found in %BRANCH_HOME%
	echo Directory %TEST_HOME% must exist and contain a Vagrantfile
	pause
	exit 2
)

echo Running "vagrant renew" in "%TEST_HOME%"
cd %TEST_HOME%
vagrant destroy --force
vagrant up

pause
