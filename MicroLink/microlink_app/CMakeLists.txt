# Copyright (c) 2021 HPMicro
# SPDX-License-Identifier: BSD-3-Clause

cmake_minimum_required(VERSION 3.13)

set(APP_NAME "MicroLink")
set(CONFIG_CHERRYUSB 1)
set(CONFIG_CHERRYRB 1)
set(CONFIG_USB_DEVICE 1)
set(CONFIG_USB_DEVICE_MSC 1)
set(CONFIG_USB_DEVICE_CDC 1)
set(CONFIG_DMA_MGR 1)
set(CONFIG_FATFS 1)
set(CONFIG_RAMFLASH 1)

set(CUSTOM_GCC_LINKER_FILE ${CMAKE_CURRENT_SOURCE_DIR}/linkers/gcc/flash_xip.ld)
set(CUSTOM_SES_LINKER_FILE ${CMAKE_CURRENT_SOURCE_DIR}/linkers/segger/flash_xip.icf)
set(CUSTOM_IAR_LINKER_FILE ${CMAKE_CURRENT_SOURCE_DIR}/linkers/iar/flash_xip.icf)


# the following lines before "### END ###" are added during project localization
### START ###
set(ENV{HPM_SDK_BASE} "${CMAKE_CURRENT_SOURCE_DIR}/hpm_sdk_localized_for_hpm5301evklite")
set(LOCALIZED_BOARD "hpm5301evklite")
if(BOARD)
  if(NOT ${BOARD} MATCHES ${LOCALIZED_BOARD})
    message(FATAL_ERROR "ABORT:\n hpm sdk has been localized for ${LOCALIZED_BOARD} already.")
  endif()
endif()
set(BOARD ${LOCALIZED_BOARD})
### END ###


find_package(hpm-sdk REQUIRED HINTS $ENV{HPM_SDK_BASE})

project(microlink_app)

# 设置版本号
if (EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/.version)
    file(STRINGS ${CMAKE_CURRENT_SOURCE_DIR}/.version BUILD_VERSION)
    string(STRIP ${BUILD_VERSION} BUILD_VERSION)
    set(CONFIG_BUILD_VERSION ${BUILD_VERSION})
endif ()


if(DEFINED CONFIG_RAMFLASH)
  sdk_compile_definitions(-DRAM_FLASH_FATFS_ENABLE=1)
  sdk_compile_definitions(-DFAT_ON_CHIP_FLASH_OFFSET=0x72000)
  sdk_compile_definitions(-DFAT_ON_CHIP_FLASH_BLOCK_NUM=140)
endif()

sdk_app_inc(${CMAKE_CURRENT_SOURCE_DIR})
sdk_app_inc(../external/pikapython/pikascript-api)
sdk_app_inc(../external/pikapython/pikascript-core)
sdk_app_inc(../external/pikapython/pikascript-lib/PikaStdLib)
sdk_app_inc(../external/pikapython/pikascript-lib/RTTView)
sdk_app_inc(../external/pikapython/pikascript-lib/PikaStdDevice)
sdk_app_inc(../external/MicroBoot/source)
sdk_app_inc(../external/MicroBoot/source/flash_algo)
sdk_inc(../external/DAP/Include)
sdk_app_inc(config)
sdk_app_inc(src)
sdk_app_inc(src/JTAG_DP)
sdk_app_inc(src/SW_DP)
sdk_app_inc(src/swd_host)
sdk_app_inc(src/USB2UART)
sdk_app_inc(src/USB2Python)
sdk_app_inc(src/USB2MSC)
sdk_app_inc(src/ymodem_send)
sdk_app_inc(vfs)
sdk_app_inc(vfs/target)
sdk_app_inc(vfs/drag-n-drop)
sdk_app_inc(vfs/cmsis-core)


sdk_app_src_glob(../external/MicroBoot/source/check_agent_engine/*.c)
sdk_app_src_glob(../external/MicroBoot/source/communication/*.c)
sdk_app_src_glob(../external/MicroBoot/source/generic/*.c)
sdk_app_src(../external/DAP/Source/DAP_vendor.c)
sdk_app_src(../external/DAP/Source/DAP.c)
sdk_app_src(../external/DAP/Source/SW_DP.c)
sdk_app_src(../external/DAP/Source/JTAG_DP.c)
sdk_app_src_glob(../external/pikapython/pikascript-lib/*.c)
sdk_app_src_glob(../external/pikapython/pikascript-core/*.c)
sdk_app_src_glob(../external/pikapython/pikascript-api/*.c)
sdk_app_src_glob(src/*.c)
sdk_app_src(config/user_app_cfg.h)
sdk_app_src(config/usb_config.h)
sdk_app_src(config/DAP_config.h)
sdk_app_src(config/pika_config.h)
sdk_app_src(config/pika_config.c)
sdk_app_src_glob(vfs/*.c)


# swj_clock default use keil swd frequency boost
sdk_compile_definitions(-DBOOST_KEIL_SWD_FREQ=0)

if (CONFIG_BUILD_VERSION)
    sdk_compile_definitions(-DCONFIG_BUILD_VERSION="${CONFIG_BUILD_VERSION}")
else ()
    sdk_compile_definitions(-DCONFIG_BUILD_VERSION="Debug")
endif ()

sdk_compile_definitions(-D__USER_APP_CFG_H__="user_app_cfg.h")
sdk_compile_definitions(-DPRODUCT_STRING="MicroLink Pro")
sdk_compile_definitions(-DCONFIG_USB_HS)
sdk_compile_definitions(-DCONFIG_CHERRYDAP_USE_MSC)
sdk_compile_definitions(-DPIKA_CONFIG_ENABLE)
sdk_compile_definitions(-DFF_CODE_PAGE=437)
sdk_compile_options("-O3")

generate_ide_projects()

