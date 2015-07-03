LOCAL_PATH := $(call my-dir)

######################################################
###                     sl                         ###
######################################################
include $(CLEAR_VARS)
LOCAL_SRC_FILES := sl.c
LOCAL_STATIC_LIBRARIES := libncurses
LOCAL_C_INCLUDES += external/ncurses/include 

LOCAL_MODULE_PATH := $(TARGET_OUT_OPTIONAL_EXECUTABLE)
LOCAL_MODULE_TAGS := debug
LOCAL_MODULE := sl

#LOCAL_MULTILIB := both
#LOCAL_MODULE_STEM_64 := $(LOCAL_MODULE)64
#LOCAL_MODULE_STEM_32 := $(LOCAL_MODULE)32

include $(BUILD_EXECUTABLE)

######################################################
###                     sl-h                       ###
######################################################
include $(CLEAR_VARS)
LOCAL_SRC_FILES := sl-h.c
LOCAL_STATIC_LIBRARIES := libncurses
LOCAL_C_INCLUDES += external/ncurses/include 

#LOCAL_CFLAGS := -DANDROID -DANDROID_TILE_BASED_DECODE -DENABLE_ANDROID_NULL_CONVERT
LOCAL_MODULE_PATH := $(TARGET_OUT_OPTIONAL_EXECUTABLE)
LOCAL_MODULE_TAGS := debug
LOCAL_MODULE := sl-h

#LOCAL_MULTILIB := both
#LOCAL_MODULE_STEM_64 := $(LOCAL_MODULE)64
#LOCAL_MODULE_STEM_32 := $(LOCAL_MODULE)32

include $(BUILD_EXECUTABLE)

######################################################
###                 libjpeg-test.sh                ###
######################################################
include $(CLEAR_VARS)
LOCAL_MODULE := sl.sh
LOCAL_SRC_FILES := sl.sh
LOCAL_MODULE_CLASS := EXECUTABLES
LOCAL_MODULE_TAGS := debug
LOCAL_MODULE_PATH := $(TARGET_OUT_OPTIONAL_EXECUTABLE)
include $(BUILD_PREBUILT)
