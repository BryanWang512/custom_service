LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_MODULE := lua-prebuilt
LOCAL_SRC_FILES := $(LOCAL_PATH)/../reference/$(TARGET_ARCH_ABI)/liblua.so
LOCAL_EXPORT_C_INCLUDES := $(LOCAL_PATH)/inc
include $(PREBUILT_SHARED_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE := mqtt
LOCAL_SRC_FILES := \
$(LOCAL_PATH)/../../src/main.cpp \
$(LOCAL_PATH)/../../src/mqtt/Clients.c \
$(LOCAL_PATH)/../../src/mqtt/Heap.c \
$(LOCAL_PATH)/../../src/mqtt/LinkedList.c \
$(LOCAL_PATH)/../../src/mqtt/Log.c \
$(LOCAL_PATH)/../../src/mqtt/Messages.c \
$(LOCAL_PATH)/../../src/mqtt/MQTTAsync.c \
$(LOCAL_PATH)/../../src/mqtt/MQTTPacket.c \
$(LOCAL_PATH)/../../src/mqtt/MQTTPacketOut.c \
$(LOCAL_PATH)/../../src/mqtt/MQTTPersistence.c \
$(LOCAL_PATH)/../../src/mqtt/MQTTPersistenceDefault.c \
$(LOCAL_PATH)/../../src/mqtt/MQTTProtocolClient.c \
$(LOCAL_PATH)/../../src/mqtt/MQTTProtocolOut.c \
$(LOCAL_PATH)/../../src/mqtt/MQTTVersion.c \
$(LOCAL_PATH)/../../src/mqtt/Socket.c \
$(LOCAL_PATH)/../../src/mqtt/SocketBuffer.c \
$(LOCAL_PATH)/../../src/mqtt/SSLSocket.c \
$(LOCAL_PATH)/../../src/mqtt/StackTrace.c \
$(LOCAL_PATH)/../../src/mqtt/Thread.c \
$(LOCAL_PATH)/../../src/mqtt/Tree.c \
$(LOCAL_PATH)/../../src/mqtt/utf-8.c \
$(LOCAL_PATH)/../../src/jsoncpp/src/json_reader.cpp \
$(LOCAL_PATH)/../../src/jsoncpp/src/json_value.cpp \
$(LOCAL_PATH)/../../src/jsoncpp/src/json_writer.cpp \
$(LOCAL_PATH)/../../src/boyim.pb.cc \


LOCAL_C_INCLUDES := $(LOCAL_PATH)/ \
					$(LOCAL_PATH)/../../src \
					$(LOCAL_PATH)/../../src/openssl \
					$(LOCAL_PATH)/../../src/jsoncpp/include \
					$(LOCAL_PATH)/../../src/lua/include \
					$(LOCAL_PATH)/../../src/mqtt \
					$(LOCAL_PATH)/../../src/message \
					

LOCAL_CPPFLAGS += -frtti -fexceptions -fpermissive

LOCAL_SHARED_LIBRARIES := lua-prebuilt

LOCAL_LDLIBS := -llog
LOCAL_LDLIBS += -L$(call host-path, $(LOCAL_PATH)/../reference/$(TARGET_ARCH_ABI)) -lprotobuf
LOCAL_LDLIBS += E:/Download/android-ndk-r10e/sources/cxx-stl/gnu-libstdc++/4.9/libs/armeabi/libsupc++.a
LOCAL_LDLIBS += E:/Download/android-ndk-r10e/sources/cxx-stl/gnu-libstdc++/4.9/libs/armeabi/libgnustl_static.a

LOCAL_CFLAGS := -DTARGET_PLATFORM=PLATFORM_ANDROID -DFIXED_POINT -DUSE_KISS_FFT -DEXPORT="" -DMQTT_EXPORTS -UHAVE_CONFIG_H

include $(BUILD_SHARED_LIBRARY)
