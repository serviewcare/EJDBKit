#!/bin/bash
# A modified version of the cross compiler script from:
# http://tinsuke.wordpress.com/2011/02/17/how-to-cross-compiling-libraries-for-ios-armv6armv7i386/
# Yes, it's sloppy...and Yes, it needs some love but for now it will have to do.

IOS_BASE_SDK=""
IOS_DEPLOY_TGT=""

export DEVELOPER_DIR="/Applications/Xcode.app/Contents/Developer"
IOS_DEVROOT="${DEVELOPER_DIR}/Platforms/iPhoneOS.platform/Developer"
IOS_SIM_DEVROOT="${DEVELOPER_DIR}/Platforms/iPhoneSimulator.platform/Developer"
MAC_DEVROOT="${DEVELOPER_DIR}/Platforms/MacOSX.platform/Developer"

export PATH=$PATH:/usr/bin/

unsetenv()
{
        unset DEVROOT SDKROOT CFLAGS MYCFLAGS CC LD AR AS NM RANLIB LDFLAGS MYCPPFLAGS MYCXXFLAGS CPPFLAGS CXXFLAGS
}

setenv_all()
{
        TOOLCHAIN_BIN_DIR=$DEVELOPER_DIR/Toolchains/XcodeDefault.xctoolchain/usr/bin
        export CC=$TOOLCHAIN_BIN_DIR/clang
        export LD=$TOOLCHAIN_BIN_DIR/ld
        export AR=$TOOLCHAIN_BIN_DIR/ar
        export AS=$TOOLCHAIN_BIN_DIR/as
        export NM=$TOOLCHAIN_BIN_DIR/nm
        export RANLIB=$TOOLCHAIN_BIN_DIR/ranlib
        export LDFLAGS="-L$SDKROOT/usr/lib/"
        export MYCFLAGS=$CFLAGS
        export MYCPPFLAGS=$CFLAGS
        export MYCXXFLAGS=$CFLAGS
        export CPPFLAGS=$CFLAGS
        export CXXFLAGS=$CFLAGS        
}
 
setenv_arm7()
{
        unsetenv
        export DEVROOT=$IOS_DEVROOT
        export SDKROOT=$DEVROOT/SDKs/iPhoneOS$IOS_BASE_SDK.sdk
        export CFLAGS="-arch armv7 -pipe -no-cpp-precomp -isysroot $SDKROOT -I$SDKROOT/usr/include/"
        setenv_all
}

setenv_arm7s()
{
        unsetenv
        export DEVROOT=$IOS_DEVROOT
        export SDKROOT=$DEVROOT/SDKs/iPhoneOS$IOS_BASE_SDK.sdk
        export CFLAGS="-arch armv7s -pipe -no-cpp-precomp -isysroot $SDKROOT -I$SDKROOT/usr/include/"
        setenv_all
}
 
setenv_arm64()
{
        unsetenv
        export DEVROOT=$IOS_DEVROOT
        export SDKROOT=$DEVROOT/SDKs/iPhoneOS$IOS_BASE_SDK.sdk
        export CFLAGS="-arch arm64 -pipe -no-cpp-precomp -isysroot $SDKROOT -I$SDKROOT/usr/include/"
        setenv_all
}

setenv_x86_64()
{
        unsetenv
        export DEVROOT=$IOS_SIM_DEVROOT
        export SDKROOT=$DEVROOT/SDKs/iPhoneSimulator$IOS_BASE_SDK.sdk
        export CFLAGS="-arch x86_64 -pipe -no-cpp-precomp -isysroot $SDKROOT" 
        setenv_all
}

setenv_x86_64_mac()
{
        unsetenv
        export DEVROOT=$MAC_DEVROOT
        export SDKROOT=$DEVROOT/SDKs/MacOSX10.8.sdk
        export CFLAGS="-arch x86_64 -pipe -no-cpp-precomp -isysroot $SDKROOT"
        setenv_all
}

install_armv7()
{
        rm -rf $OUTDIR/build/armv7
        mkdir $OUTDIR/build/armv7
        mkdir $OUTDIR/build/armv7/lib
        make clean 2> /dev/null
        make distclean 2> /dev/null
        setenv_arm7
        ./configure --host=arm-apple-darwin7 --enable-shared=no --prefix=$OUTDIR/build/armv7
        make
        make install        
}

install_armv7s()
{
        rm -rf $OUTDIR/build/armv7s
        mkdir $OUTDIR/build/armv7s
        mkdir $OUTDIR/build/armv7s/lib
        make clean 2> /dev/null
        make distclean 2> /dev/null
        setenv_arm7s
        ./configure --host=arm-apple-darwin7 --enable-shared=no --prefix=$OUTDIR/build/armv7s
        make
        make install        
}

install_arm64()
{
        rm -rf $OUTDIR/build/arm64
        mkdir $OUTDIR/build/arm64
        mkdir $OUTDIR/build/arm64/lib
        make clean 2> /dev/null
        make distclean 2> /dev/null
        setenv_arm64
        ./configure --host=arm-apple-darwin8 --enable-shared=no --prefix=$OUTDIR/build/arm64
        make
        make install
}

unset OUTDIR
OUTDIR="`pwd`/ejdb"

if [ ! -d "$OUTDIR" ]
then
  mkdir $OUTDIR
  mkdir $OUTDIR/lib
  mkdir $OUTDIR/build
  mkdir -p $OUTDIR/include/tcejdb
  mkdir -p $OUTDIR/include/tcejdb/nix
fi

#cd to tcejdb folder
#copy header files into OUTDIR/include/tcejdb

cd ../vendor/ejdb/tcejdb
HEADER_FILES=(tcutil.h tchdb.h tcbdb.h tcfdb.h tctdb.h tcadb.h ejdb.h ejdb_private.h bson.h myconf.h basedefs.h)
for headerfile in ${HEADER_FILES[*]}
do
 cp $headerfile $OUTDIR/include/tcejdb
done
cp nix/platform.h $OUTDIR/include/tcejdb/nix/

# if no args then make every arch
# if args then do some very ugly string comparisons and if valid make for provided arg(s)

if [ $# = 0 ]
then
  install_armv7
  install_armv7s
  install_arm64
else
  for arg
  do
     # Yes..it's an ugly ass if statement and No, I don't care because...shell script is...UGLY!!! :)   
     if [[ ("$arg" != "armv7") && ("$arg" != "armv7s") && ("$arg" != "arm64") && ("$arg" != "x86_64") && ("$arg" != "x86_64_mac") && ("$arg" != "i386") ]]
     then
        echo
        echo "usage: ejdb-build.sh [architecture options]"
        echo "architecture options (0 or more): "
        echo "armv7 armv7s arm64 x86_64 x86_64_mac i386"
        echo "Supply no options if you want to build all architectures."
        echo
        exit
     fi
     install_$arg   
  done         
fi

#keep our vendor/ejdb/tcejdb folder tidy by removing generated folders/files
rm -r -f static
rm libtcejdb.a
cd -
