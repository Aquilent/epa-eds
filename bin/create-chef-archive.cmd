@echo off


if not exist %ZIP_HOME%\7z.exe (
    echo You must have 7-ZIP installed and specified in environment variable 'ZIP_HOME'
    echo 7Zip is an open source file archive you can obtain at http://www.7-zip.org
    echo     Use: set ZIP_HOME=/path/to/7zip/installation/directory
    echo     E.g.: , e.g. set ZIP_HOME="C:\Program Files\7-zip"
    pause
    exit 1
)

if exist ./setenv.cmd (
    call ./setenv.cmd
) else (
    echo No branch-specific configuration found
)

for /f "skip=1" %%x in ('wmic os get localdatetime') do if not defined DTS set DTS=%%x
SET DateTime=%DTS:~0,4%%DTS:~4,2%%DTS:~6,2%-%DTS:~8,2%%DTS:~10,2%

set SOURCE_HOME=%BRANCH_HOME:/=\%\src\main\chef
set TARGET_HOME=%BRANCH_HOME:/=\%\target
set CHEF_TARGET_HOME=%TARGET_HOME%\chef
set ARCHIVE_NAME=GSA-ADS-%BRANCH_NAME%-chef-%DateTime%
set ARCHIVE=%TARGET_HOME%\%ARCHIVE_NAME%

echo TARGET_HOME=%TARGET_HOME%
echo Create Chef archive in %ARCHIVE%

echo Removing old target directory
rd /s /q %TARGET_HOME%\chef
if exist %ARCHIVE% ( 
    echo Removing old archive %ARCHIVE%
    del /q %ARCHIVE% 
)
echo Copy Chef source directory %SOURCE_HOME% to %CHEF_TARGET_HOME%
mkdir %TARGET_HOME%
mkdir %CHEF_TARGET_HOME%
xcopy %SOURCE_HOME%\*.* %CHEF_TARGET_HOME%\ /s /q /e 

echo Creating %ARCHIVE%
REM http://sevenzip.osdn.jp/chm/cmdline/syntax.htm
%ZIP_HOME%\7z.exe a -ttar -r %ARCHIVE%.tar %CHEF_TARGET_HOME:/=\%
%ZIP_HOME%\7z.exe a -tgzip -r %ARCHIVE%.tar.gzip %ARCHIVE%.tar
del /q %ARCHIVE%.tar

echo Clean up 
rd /s /q %TARGET_HOME%\chef

if "%1" == "--pause" ( pause )
