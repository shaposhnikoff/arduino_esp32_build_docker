#!/bin/bash -x
#~/arduino-1.8.9/arduino --pref build.path=build  --verbose --verify $1

BUILD_DIR="build"

/root/arduino/arduino --pref build.path=build --pref board=esp32 --verbose --verify ESP32_aws_iot.ino
#~/arduino-1.8.9/arduino --pref build.path=build --pref board=esp32 --verbose --verify ESP32_aws_iot.ino

#~/arduino-1.8.9/arduino --verbose --verify --pref build.flash_ld=$arduino_flash_ld --pref build.path=$BUILD_DIR --pref build.f_cpu=$arduino_f_cpu --pref build.flash_size=$arduino_flash_size --pref board="esp32" ESP32_aws_iot.ino





