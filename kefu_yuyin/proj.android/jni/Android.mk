LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_MODULE := lua-prebuilt
LOCAL_SRC_FILES := $(LOCAL_PATH)/../reference/$(TARGET_ARCH_ABI)/liblua.so
LOCAL_EXPORT_C_INCLUDES := $(LOCAL_PATH)/inc
include $(PREBUILT_SHARED_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE := babe-prebuilt
LOCAL_SRC_FILES := $(LOCAL_PATH)/../reference/$(TARGET_ARCH_ABI)/libbabe.so
LOCAL_EXPORT_C_INCLUDES := $(LOCAL_PATH)/inc
include $(PREBUILT_SHARED_LIBRARY)

include $(CLEAR_VARS)

LOCAL_MODULE := kefu_yuyin

LOCAL_SRC_FILES := \
../../src/main.cpp \
../../src/byaudio_wave_header.c \
../../src/byaudio_speex.c \
../../src/speex/lib/bits.c \
../../src/speex/lib/buffer.c \
../../src/speex/lib/cb_search.c \
../../src/speex/lib/exc_10_16_table.c \
../../src/speex/lib/exc_10_32_table.c \
../../src/speex/lib/exc_20_32_table.c \
../../src/speex/lib/exc_5_256_table.c \
../../src/speex/lib/exc_5_64_table.c \
../../src/speex/lib/exc_8_128_table.c \
../../src/speex/lib/fftwrap.c \
../../src/speex/lib/filterbank.c \
../../src/speex/lib/filters.c \
../../src/speex/lib/gain_table.c \
../../src/speex/lib/gain_table_lbr.c \
../../src/speex/lib/hexc_10_32_table.c \
../../src/speex/lib/hexc_table.c \
../../src/speex/lib/high_lsp_tables.c \
../../src/speex/lib/jitter.c \
../../src/speex/lib/kiss_fft.c \
../../src/speex/lib/kiss_fftr.c \
../../src/speex/lib/lpc.c \
../../src/speex/lib/lsp.c \
../../src/speex/lib/lsp_tables_nb.c \
../../src/speex/lib/ltp.c \
../../src/speex/lib/mdf.c \
../../src/speex/lib/modes.c \
../../src/speex/lib/modes_wb.c \
../../src/speex/lib/nb_celp.c \
../../src/speex/lib/preprocess.c \
../../src/speex/lib/quant_lsp.c \
../../src/speex/lib/resample.c \
../../src/speex/lib/sb_celp.c \
../../src/speex/lib/scal.c \
../../src/speex/lib/smallft.c \
../../src/speex/lib/speex.c \
../../src/speex/lib/speex_callbacks.c \
../../src/speex/lib/speex_header.c \
../../src/speex/lib/stereo.c \
../../src/speex/lib/vbr.c \
../../src/speex/lib/vq.c \
../../src/speex/lib/window.c \


LOCAL_C_INCLUDES := $(LOCAL_PATH)/ \
					$(LOCAL_PATH)/../../src \
					$(LOCAL_PATH)/../../src/lua/include \
					$(LOCAL_PATH)/../../src/speex \
					

LOCAL_LDLIBS := -llog
LOCAL_SHARED_LIBRARIES := babe-prebuilt lua-prebuilt

#LOCAL_CFLAGS := -O2
LOCAL_CFLAGS := -DTARGET_PLATFORM=PLATFORM_ANDROID -DFIXED_POINT -DUSE_KISS_FFT -DEXPORT="" -UHAVE_CONFIG_H

include $(BUILD_SHARED_LIBRARY)
