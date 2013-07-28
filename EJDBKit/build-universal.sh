XCODEBUILD_PATH=/Applications/Xcode.app/Contents/Developer/usr/bin
XCODEBUILD=$XCODEBUILD_PATH/xcodebuild

$XCODEBUILD -project EJDBKit.xcodeproj -target "EJDBKit" -sdk "iphonesimulator" -configuration "Release" clean build
$XCODEBUILD -project EJDBKit.xcodeproj -target "EJDBKit" -sdk "iphoneos" -configuration "Release" clean build

lipo -create -output "build/libEJDBKit.a" "build/Release-iphoneos/libEJDBKit.a" "build/Release-iphonesimulator/libEJDBKit.a"

