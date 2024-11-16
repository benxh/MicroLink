/**
 * @file    flash_blob.h
 * @brief
 *
 * DAPLink Interface Firmware
 * Copyright (c) 2009-2016, ARM Limited, All Rights Reserved
 * Copyright 2019, Cypress Semiconductor Corporation 
 * or a subsidiary of Cypress Semiconductor Corporation.
 * SPDX-License-Identifier: Apache-2.0
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may
 * not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#ifndef FLASH_BLOB_H
#define FLASH_BLOB_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

// Flags for program_target
enum { 
    kAlgoVerifyReturnsAddress = (1u << 0u),     /*!< Verify function returns address if bit set */
    kAlgoSingleInitType =       (1u << 1u),     /*!< The init function ignores the function code. */
    kAlgoSkipChipErase =        (1u << 2u),     /*!< Skip region when erase.act action triggers. */
};

typedef struct __attribute__((__packed__)) {
    uint32_t breakpoint;
    uint32_t static_base;
    uint32_t stack_pointer;
} program_syscall_t;

typedef struct __attribute__((__packed__)) {
    const uint32_t  init;
    const uint32_t  uninit;
    const uint32_t  erase_chip;
    const uint32_t  erase_sector;
    const uint32_t  program_page;
    const uint32_t  verify;
    const program_syscall_t sys_call_s;
    const uint32_t  program_buffer;
    const uint32_t  algo_start;
    const uint32_t  algo_size;
    const uint32_t *algo_blob;
    const uint32_t  program_buffer_size;
    const uint32_t  algo_flags;         /*!< Combination of kAlgoVerifyReturnsAddress, kAlgoSingleInitType and kAlgoSkipChipErase*/
} program_target_t;


#define SECTOR_NUM 16         // Max Number of Sector Items

#define FLASH_DRV_VERS (0x0100+VERS)

#define SECTOR_END 0xFFFFFFFF, 0xFFFFFFFF

struct FlashSectors  {
    unsigned long   szSector;    // Sector Size in Bytes
    unsigned long   AddrSector;    // Address of Sector
};

typedef struct FlashDevice  {
   unsigned short     Vers;    // Version Number and Architecture
   char       DevName[128];    // Device Name and Description
   unsigned short  DevType;    // Device Type: ONCHIP, EXT8BIT, EXT16BIT, ...
   unsigned long    DevAdr;    // Default Device Start Address
   unsigned long     szDev;    // Total Size of Device
   unsigned long    szPage;    // Programming Page Size
   unsigned long       Res;    // Reserved for future Extension
   unsigned char  valEmpty;    // Content of Erased Memory

   unsigned long    toProg;    // Time Out of Program Page Function
   unsigned long   toErase;    // Time Out of Erase Sector Function

   struct FlashSectors sectors[SECTOR_NUM];
} flash_dev_t;

#ifdef __cplusplus
}
#endif

#endif
