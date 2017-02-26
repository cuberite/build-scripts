#!/usr/bin/env bash

set -e

# Parse arguments.
while [[ $# -gt 1 ]]
do
key="$1"
case $key in
    -s|--server-name)
    SERVERNAME="$2"
    shift
    ;;
    -c|--compiler)
    CCOMP="$2"
    shift
    ;;
    -cxx|--cxx-compiler)
    CXXCOMP="$2"
    shift
    ;;
	-m|--compile-mode)
	COMPILEMODE="$2"
	shift
	;;
    -n|--build-number)
	BUILDID="$2"
	shift
	;;
	-b|--branch)
	BRANCH="$2"
	shift
    ;;
	-32|--force-32)
	FORCE32="$2"
	shift
	;;
    *)
    ;;
esac
shift
done

# Clone repository.
git clone --depth 1 https://github.com/cuberite/cuberite.git -b $BRANCH
pushd cuberite
git submodule update --init

# Set up build information.
export CUBERITE_BUILD_SERIES_NAME="$SERVERNAME $CCOMP x64 $COMPILEMODE ($BRANCH)"
export CUBERITE_BUILD_ID="$BUILDID"
export CUBERITE_BUILD_DATETIME="`date`"

# Build
CXX=$CXXCOMP CC=$CCOMP cmake . -DNO_NATIVE_OPTIMIZATION=1 -DCMAKE_BUILD_TYPE=${COMPILEMODE^^} -DFORCE_32=${FORCE32^^}
make

# Package Server
cp -r Install/ThirdPartyLicenses/ Server/
cp CONTRIBUTORS Server/
cp LICENSE Server/
rm Server/delete_windows_service.cmd Server/hg Server/hg.supp Server/install_windows_service.cmd Server/Plugins/.gitignore Server/vg Server/vg.supp
tar -cvzf Cuberite.tar.gz Server/*
sha1sum Cuberite.tar.gz > Cuberite.tar.gz.sha1
