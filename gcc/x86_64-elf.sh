#!/bin/bash

. ./env.sh
. ./base.sh

DUMP_MACHINE="$(gcc -dumpmachine)"
TARGET_MACHINE="x86_64-elf"

BUILD_ROOT="$TOOLCHAINS_BUILD/build"
PREFIX_ROOT="$TOOLCHAINSPATH"

CROSS_BINUTILS_GDB_CONFIGURE="--disable-nls --disable-werror --with-python3 --enable-gold"
CROSS_GCC_CONFIGURE+=" --without-headers"
CROSS_GCC_CONFIGURE+=" --disable-shared"
CROSS_GCC_CONFIGURE+=" --disable-shared"
CROSS_GCC_CONFIGURE+=" --disable-threads"
CROSS_GCC_CONFIGURE+=" --disable-nls"
CROSS_GCC_CONFIGURE+=" --disable-werror"
CROSS_GCC_CONFIGURE+=" --disable-libssp"
CROSS_GCC_CONFIGURE+=" --disable-libquadmath"
CROSS_GCC_CONFIGURE+=" --disable-libbacktarce"
CROSS_GCC_CONFIGURE+=" --enable-languages=c,c++"
CROSS_GCC_CONFIGURE+=" --enable-multilib"
CROSS_GCC_CONFIGURE+=" --disable-bootstrap"
CROSS_GCC_CONFIGURE+=" --disable-libstdcxx-verbose"
CROSS_GCC_CONFIGURE+=" --with-libstdcxx-eh-pool-obj-count=0"
CROSS_GCC_CONFIGURE+=" --disable-sjlj-exceptions"
CROSS_GCC_CONFIGURE+=" --disable-hosted-libstdcxx"
CROSS_GCC_CONFIGURE+=" --with-gxx-libcxx-include-dir=$(libcxx_include_dir $PREFIX_ROOT $DUMP_MACHINE $DUMP_MACHINE $TARGET_MACHINE)"
# CROSS_GCC_CONFIGURE="--without-headers --disable-shared --disable-threads --disable-nls --disable-werror --disable-libssp --disable-libquadmath --disable-libbacktarce --enable-languages=c,c++ --enable-multilib --disable-bootstrap --disable-libstdcxx-verbose --with-libstdcxx-eh-pool-obj-count=0 --disable-sjlj-exceptions --disable-hosted-libstdcxx --with-gxx-libcxx-include-dir=$(libcxx_include_dir $PREFIX_ROOT $DUMP_MACHINE $DUMP_MACHINE $TARGET_MACHINE)"

auto_build_gcc_toolchains 	\
	"$1" 					\
	$DUMP_MACHINE 			\
	$DUMP_MACHINE 			\
	$TARGET_MACHINE 		\
	$TOOLCHAINS_BUILD 		\
	$BUILD_ROOT 			\
	$PREFIX_ROOT			\
	"$CROSS_BINUTILS_GDB_CONFIGURE"\
	"$CROSS_GCC_CONFIGURE"
