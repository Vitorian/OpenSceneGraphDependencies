#!/bin/bash
# Open MSYS2 
# ./build.sh 
# If everything goes alright, the build code will be in $PWD/build/3rdParty/v140-x64/
#
SCRIPTFILE="$(readlink -f $0)"
SCRIPTDIR="$(dirname $SCRIPTFILE)"
SCRIPTDIR_WIN="$(cygpath -w "$SCRIPTDIR")"

if [ "x" == "x$VS140COMNTOOLS" ]; then
    echo "You need to have Visual Studio 14 (2015) installed (Env variable VS140COMNTOOLS does not exist)"
	exit 0
fi

#echo "SCRIPTFILE:$SCRIPTFILE"
#echo "SCRIPTDIR:$SCRIPTDIR"
#exit 0

if [ ! -d "$SCRIPTDIR/Tarball" ]; then
	mkdir -p "$SCRIPTDIR/Tarball"
fi

############################################################################
# Download dependencies
# CURL FREETYPE GIFLIB GLUT JPEGSRC LIBPNG MINIZIP TIFF ZLIB
CURL_VERSION="7.56.1"
FREETYPE_VERSION="2.8.1"
GIFLIB_VERSION="5.1.4"
GLUT_VERSION=""
JPEGSRC_VERSION=""
LIBPNG_VERSION=""
MINIZIP_VERSION=""
TIFF_VERSION=""
ZLIB_VERSION=""

############################################################################
# Curl 
if [ ! -f "$SCRIPTDIR/Tarball/curl-${CURL_VERSION}.tar.gz" ]; then
	wget "https://curl.haxx.se/download/curl-${CURL_VERSION}.tar.gz" -O "$SCRIPTDIR/Tarball/curl-${CURL_VERSION}.tar.gz"
fi
rm -rf "curl-${CURL_VERSION}"
tar xzvf "$SCRIPTDIR/Tarball/curl-${CURL_VERSION}.tar.gz" -C "$SCRIPTDIR"
rsync -av "$SCRIPTDIR/curl-${CURL_VERSION}/" "$SCRIPTDIR/curl/"

############################################################################
# FreeType2
if [ ! -f "$SCRIPTDIR/Tarball/freetype-${FREETYPE_VER}.tar.gz" ]; then
	wget "https://sourceforge.net/projects/freetype/files/freetype2/${FREETYPE_VERSION}/freetype-${FREETYPE_VERSION}.tar.gz" -O "$SCRIPTDIR/Tarball/freetype-${FREETYPE_VERSION}.tar.gz"
fi
rm -rf freetype-${FREETYPE_VERSION}
tar xzvf "$SCRIPTDIR/Tarball/freetype-${FREETYPE_VERSION}.tar.gz"	-C "$SCRIPTDIR"
rsync -av "$SCRIPTDIR/freetype-${FREETYPE_VERSION}/" "$SCRIPTDIR/freetype/"

############################################################################
# Giflib
if [ ! -f "$SCRIPTDIR/Tarball/freetype-${FREETYPE_VER}.tar.gz" ]; then
	wget "https://sourceforge.net/projects/giflib/files/giflib-${GIFLIB_VERSION}.tar.gz" -O "$SCRIPTDIR/Tarball/giflib-${GIFLIB_VERSION}.tar.gz"
fi
rm -rf giflib-${GIFLIB_VERSION}
tar xzvf "$SCRIPTDIR/Tarball/giflib-${GIFLIB_VERSION}.tar.gz"	-C "$SCRIPTDIR"
rsync -av "$SCRIPTDIR/giflib-${GIFLIB_VERSION}/" "$SCRIPTDIR/giflib/"

############################################################################
# GLUT
if [ ! -d "$SCRIPTDIR/glut.git" ]; then
	( cd "$SCRIPTDIR"; git clone https://github.com/markkilgard/glut glut.git; 	git reset --hard 8cd96cb440f1f2fac3a154227937be39d06efa53 )
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




 