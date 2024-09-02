#!/bin/bash

ROOT_PATH=$(realpath .)/artifacts
if [ ! -d ${ROOT_PATH} ]; then
	mkdir ${ROOT_PATH}
fi

if [ -z ${TOOLCHAINS_BUILD+x} ]; then
	TOOLCHAINS_BUILD=$ROOT_PATH/toolchains_build
fi

if [ -z ${TOOLCHAINSPATH+x} ]; then
	TOOLCHAINSPATH=$ROOT_PATH/toolchains
fi

echo "==========export env========="
echo "ROOT_PATH = $ROOT_PATH"
echo "TOOLCHAINS_BUILD = $TOOLCHAINS_BUILD"
echo "TOOLCHAINS_PATH = $TOOLCHAINSPATH"
echo ""