#ifndef __HOST_H__
#define __HOST_H__

#define PLATFORM_IOS     1
#define PLATFORM_ANDROID 2
#define PLATFORM_WIN32   7
#define PLATFORM_WP8	15

#if (TARGET_PLATFORM==PLATFORM_IOS)
#include <unistd.h>
typedef long long _long;
#endif

#if (TARGET_PLATFORM==PLATFORM_ANDROID)
#include <android/log.h>
typedef long long _long;
#endif

#if (TARGET_PLATFORM==PLATFORM_WIN32)
typedef __int64 _long;
#endif

#if (TARGET_PLATFORM==PLATFORM_WP8)
typedef __int64 _long;
#include <time.h>
#include <thread>
#include <chrono>
#endif

#endif /* __HOST_H__ */