wget https://developer.qualcomm.com/download/db410c/firmware-410c-1.4.0.bin
chmod +x firmware-410c-1.4.0.bin
./firmware-410c-1.4.0.bin

rm ./firmware-410c-1.4.0.bin

mkdir -p vendor/qcom/db410c/proprietary
cp -r linux-board-support-package-v1.4/proprietary-linux/*  vendor/qcom/db410c/proprietary/

rm -rf linux-board-support-package-v1.4


# Write flash-all.sh
cat > vendor/qcom/db410c/device-partial.mk << EOF
# Copyright 2017 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Qualcomm blob(s) necessary for db410c hardware
PRODUCT_COPY_FILES := \
    vendor/qcom/db410c/proprietary/wcnss.b00:system/vendor/firmware/wcnss.b00:qcom \
    vendor/qcom/db410c/proprietary/wcnss.b01:system/vendor/firmware/wcnss.b01:qcom \
    vendor/qcom/db410c/proprietary/wcnss.b02:system/vendor/firmware/wcnss.b02:qcom \
    vendor/qcom/db410c/proprietary/wcnss.b04:system/vendor/firmware/wcnss.b04:qcom \
    vendor/qcom/db410c/proprietary/wcnss.b06:system/vendor/firmware/wcnss.b06:qcom \
    vendor/qcom/db410c/proprietary/wcnss.b09:system/vendor/firmware/wcnss.b09:qcom \
    vendor/qcom/db410c/proprietary/wcnss.b10:system/vendor/firmware/wcnss.b10:qcom \
    vendor/qcom/db410c/proprietary/wcnss.b11:system/vendor/firmware/wcnss.b11:qcom \
    vendor/qcom/db410c/proprietary/wcnss.mdt:system/vendor/firmware/wcnss.mdt:qcom \
    vendor/qcom/db410c/proprietary/wlan/prima/WCNSS_qcom_wlan_nv.bin:system/vendor/firmware/wlan/prima/WCNSS_qcom_wlan_nv.bin \
    vendor/qcom/db410c/proprietary/wlan/prima/WCNSS_qcom_cfg.ini:system/vendor/firmware/wlan/prima/WCNSS_qcom_cfg.ini \
    vendor/qcom/db410c/proprietary/wlan/prima/WCNSS_cfg.dat:system/vendor/firmware/wlan/prima/WCNSS_cfg.dat \
    vendor/qcom/db410c/proprietary/wlan/prima/WCNSS_wlan_dictionary.dat:system/vendor/firmware/wlan/prima/WCNSS_wlan_dictionary.dat \
    vendor/qcom/db410c/proprietary/a300_pfp.fw:system/vendor/firmware/a300_pfp.fw \
    vendor/qcom/db410c/proprietary/a300_pm4.fw:system/vendor/firmware/a300_pm4.fw \

EOF
