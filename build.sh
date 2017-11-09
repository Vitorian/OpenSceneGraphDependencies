#!/bin/bash

if [ "x" == "x$VS140COMNTOOLS" ]; then
    echo "You need to have Visual Studio 14 (2015) installed (Env variable VS140COMNTOOLS does not exist)"
	exit 0
fi

function runbat()
{
echo "Running $*"
cat <<EOF > run.$$.bat
@echo off
env > Environment.before.log
call "%VS140COMNTOOLS%\..\..\VC\vcvarsall.bat" x86_amd64 
env > Environment.after.log
$* > runbat.$$.log
EOF
cmd.exe /c "run.$$.bat"
}

SCRIPTNAME="$(readlink -f $0)"
SCRIPTDIR="$(dirname "$SCRIPTNAME")"
SCRIPTDIR_WIN="$(cygpath -w "$SCRIPTDIR")"
if [ -d "SCRIPTDIR/build" ]; then
	rm -rf $SCRIPTDIR/build
fi

mkdir -p $SCRIPTDIR/build
cd $SCRIPTDIR/build

runbat cmake -G \"Visual Studio 14 2015 Win64\" "$SCRIPTDIR_WIN"
cd $SCRIPTDIR/build
echo "Current directory: $PWD"
runbat cmake --build . --config Release --target ALL_BUILD
runbat cmake --build . --config Release --target INSTALL




 