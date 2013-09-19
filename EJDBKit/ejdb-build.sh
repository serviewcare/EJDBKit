#!/bin/sh
## A modified version of the cross compiler script from:
## http://tinsuke.wordpress.com/2011/02/17/how-to-cross-compiling-libraries-for-ios-armv6armv7i386/

IOS_BASE_SDK="7.0"
IOS_DEPLOY_TGT="6.1"

export DEVELOPER_DIR="/Applications/Xcode.app/Contents/Developer"
IOS_DEVROOT="${DEVELOPER_DIR}/Platforms/iPhoneOS.platform/Developer"
IOS_SIM_DEVROOT="${DEVELOPER_DIR}/Platforms/iPhoneSimulator.platform/Developer"


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
        export CFLAGS="-arch armv7 -pipe -no-cpp-precomp -isysroot $SDKROOT -miphoneos-version-min=$IOS_DEPLOY_TGT -I$SDKROOT/usr/include/"
        setenv_all
}

setenv_arm7s()
{
        unsetenv
        export DEVROOT=$IOS_DEVROOT
        export SDKROOT=$DEVROOT/SDKs/iPhoneOS$IOS_BASE_SDK.sdk
        export CFLAGS="-arch armv7s -pipe -no-cpp-precomp -isysroot $SDKROOT -miphoneos-version-min=$IOS_DEPLOY_TGT -I$SDKROOT/usr/include/"
        setenv_all
}
 
setenv_arm64()
{
        unsetenv
        export DEVROOT=$IOS_DEVROOT
        export SDKROOT=$DEVROOT/SDKs/iPhoneOS$IOS_BASE_SDK.sdk
        export CFLAGS="-arch arm64 -pipe -no-cpp-precomp -isysroot $SDKROOT -miphoneos-version-min=7.0 -I$SDKROOT/usr/include/"
        setenv_all
}

setenv_x86_64()
{
        unsetenv
        export DEVROOT=$IOS_SIM_DEVROOT
        export SDKROOT=$DEVROOT/SDKs/iPhoneSimulator$IOS_BASE_SDK.sdk
        export CFLAGS="-arch x86_64 -pipe -no-cpp-precomp -isysroot $SDKROOT -miphoneos-version-min=7.0" 
        setenv_all
}

setenv_i386()
{
        unsetenv
        export DEVROOT=$IOS_SIM_DEVROOT
        export SDKROOT=$DEVROOT/SDKs/iPhoneSimulator$IOS_BASE_SDK.sdk
        export CFLAGS="-arch i386 -pipe -no-cpp-precomp -isysroot $SDKROOT -miphoneos-version-min=$IOS_DEPLOY_TGT"
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

install_x86_64()
{
        rm -rf $OUTDIR/build/x86_64
        mkdir $OUTDIR/build/x86_64
        mkdir $OUTDIR/build/x86_64/lib
        make clean 2> /dev/null
        make distclean 2> /dev/null
        setenv_x86_64
        ./configure --host=arm-apple-darwin7 --enable-shared=no --prefix=$OUTDIR/build/x86_64
        make
        make install        
}

install_i386()
{
        rm -rf $OUTDIR/build/i386
        mkdir $OUTDIR/build/i386
        mkdir $OUTDIR/build/i386/lib
        make clean 2> /dev/null
        make distclean 2> /dev/null
        setenv_i386
        ./configure --enable-shared=no --prefix=$OUTDIR/build/i386
        make
        make install        
}

unset OUTDIR
OUTDIR="`pwd`/ejdb"

pushd ../vendor/ejdb/tcejdb

rm -rf $OUTDIR/build
mkdir $OUTDIR/build

install_armv7
install_armv7s
install_arm64
install_x86_64
install_i386

popd
pushd ejdb
popd