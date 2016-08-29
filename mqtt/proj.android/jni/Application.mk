NDK_TOOLCHAIN_VERSION := 4.9
# APP_STL := stlport_shared  --> does not seem to contain C++11 features
APP_STL := gnustl_static
# Enable c++11 extentions in source code
APP_CPPFLAGS += -std=c++11
#STLPORT_FORCE_REBUILD := true

APP_PLATFORM := android-18

APP_OPTIM := release

APP_ABI := armeabi armeabi-v7a   # x86

APP_MODULES := mqtt