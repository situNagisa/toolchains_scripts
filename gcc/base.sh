#!/bin/bash

function build_dir()
{
	local ROOT="$1"
	local BUILD="$2"
	local HOST="$3"
	local TARGET="$4"
	local SOFT="$5"
	
	echo "$ROOT/$HOST/$TARGET/$SOFT"
}

function prefix_dir()
{
	local ROOT="$1"
	local BUILD="$2"
	local HOST="$3"
	local TARGET="$4"
	local SOFT="$5"
	
	echo "$ROOT/$HOST/$TARGET"
}

function libcxx_include_dir()
{
	local ROOT="$1"
	local BUILD="$2"
	local HOST="$3"
	local TARGET="$4"

	echo "$(prefix_dir $ROOT $BUILD $HOST $TARGET "gcc")/$TARGET/include/c++/v1"
}

# soft build host target src_root build_dir prefix_dir configure
function build_target()
{
	local SOFT="$1"

	local BUILD="$2"
	local HOST="$3"
	local TARGET="$4"

	local SRC_DIR="$5"
	local BUILD_DIR="$6"
	local PREFIX_DIR="$7"
	
	local CONFIGURE="${@:8}"

	local TRIPLETS="--build=$BUILD --host=$HOST --target=$TARGET"

	mkdir -p $BUILD_DIR
	cd $BUILD_DIR

	echo "=========build target========"
	echo "soft: $SOFT "
	echo "triplets: $BUILD, $HOST, $TARGET"
	echo "src: $SRC_DIR"
	echo "build: $BUILD_DIR"
	echo "prefix: $PREFIX_DIR"
	echo "configure: $CONFIGURE"
	echo ""

	if [ ! -f Makefile ]; then
		$SRC_DIR/configure $CONFIGURE $TRIPLETS --prefix=$PREFIX_DIR

		if [ $? -ne 0 ]; then
			echo "fail to configure: $SRC_DIR/configure $CONFIGURE $TRIPLETS --prefix=$PREFIX_DIR"
			exit 1
		fi
	fi
	echo "$SRC_DIR/configure $CONFIGURE $TRIPLETS --prefix=$PREFIX_DIR"

	if [ ! -d $PREFIX_DIR/lib/bfd-plugins ];then
		make -j$(nproc)
		if [ $? -ne 0 ]; then
			echo "fail to make $SOFT"
			exit 1
		fi
		make install-strip -j$(nproc)
		if [ $? -ne 0 ]; then
			echo "fail to install $SOFT"
			exit 1
		fi
	fi
}

# build host target src_dir build_dir prefix_dir configure
function auto_build()
{
	local OPERATION="$1"
	local SOFT="$2"
	local BUILD="$3"
	local HOST="$4"
	local TARGET="$5"

	local SRC_DIR="$6"
	local BUILD_ROOT="$7"
	local PREFIX_ROOT="$8"
	
	local CONFIGURE="${@:9}"

	local BUILD_DIR="$(build_dir $BUILD_ROOT $BUILD $HOST $TARGET $SOFT)"
	local PREFIX_DIR="$(prefix_dir $PREFIX_ROOT $BUILD $HOST $TARGET $SOFT)"

	cd $SRC_DIR
	git pull --quiet
	if [ $? -ne 0 ]; then
		echo "fail to git pull on: $SRC_DIR"
		# exit 1
	fi

	if [[ $OPERATION == "restart" ]]; then
		echo "restarting"
		rm -rf $BUILD_DIR
		rm -rf $PREFIX_DIR
		echo "restart done"
	fi

	build_target $SOFT $BUILD $HOST $TARGET $SRC_DIR $BUILD_DIR $PREFIX_DIR $CONFIGURE
}

function auto_build_gcc_toolchains()
{
	local OPERATION="$1"
	local BUILD="$2"
	local HOST="$3"
	local TARGET="$4"

	local SRC_ROOT="$5"
	local BUILD_ROOT="$6"
	local PREFIX_ROOT="$7"

	local BINUTILS_GDB_CONFIGURE="$8"
	local GCC_CONFIGURE="$9"

	auto_build			\
		"$OPERATION"	\
		"binutils-gdb"	\
		$BUILD			\
		$HOST			\
		$TARGET			\
		"$SRC_ROOT/binutils-gdb"\
		$BUILD_ROOT		\
		$PREFIX_ROOT	\
		"$BINUTILS_GDB_CONFIGURE"

	GCC_PREFIX_DIR=$(prefix_dir $PREFIX_ROOT $DUMP_MACHINE $DUMP_MACHINE $TARGET "gcc")

	auto_build			\
		"$OPERATION"	\
		"gcc"			\
		$BUILD			\
		$HOST			\
		$TARGET			\
		"$SRC_ROOT/gcc"	\
		$BUILD_ROOT		\
		$PREFIX_ROOT	\
		"$GCC_CONFIGURE"

	if [ ! -f $GCC_PREFIX_DIR/bin/$TARGET-cc ]; then
		cd $GCC_PREFIX_DIR/bin
		ln -s $TARGET-gcc $TARGET-cc
	fi
}