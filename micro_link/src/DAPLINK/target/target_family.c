/**
 * @file    target_family.c
 * @brief   Implementation of target_family.h
 *
 * DAPLink Interface Firmware
 * Copyright (c) 2009-2019, ARM Limited, All Rights Reserved
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
#include "stdio.h"
#include "DAP_config.h"
#include "swd_host.h"
#include "target_family.h"
#include "target_board.h"
#include "core_cm3.h"
#include "target_config.h"

#ifndef RAM_BASE
#define RAM_BASE 0x20000000
#endif

#ifndef RAM_SIZE
#define RAM_SIZE 0x20000
#endif

#include "st/STM32F10x_128.FLM.c"
#include "st/STM32F10x_512.FLM.c"
#include "st/STM32F10x_1024.FLM.c"
#include "st/STM32F4xx_1024.FLM.c"
#include "st/STM32H7x_2048.FLM.c"
#include "st/STM32G4xx_512.FLM.c"
#include "gd/GD32E50x_512.FLM.c"
#include "gd/GD32F30x_HD.FLM.c"

target_cfg_t target_device = {
    .version                        = kTargetConfigVersion,
    .flash_regions[0].flags         = kRegionIsDefault,
    .ram_regions[0].start           = RAM_BASE,
    .ram_regions[0].end             = RAM_BASE + RAM_SIZE,
    .target_vendor                  = NULL,
    .target_part_number             = NULL,
};

uint32_t get_chip_id(void)
{
    uint32_t family_id = get_family_id();
    uint16_t deviceID = family_id & 0xFFF;  // 设备ID位于低12位
    uint16_t revisionID = (family_id >> 16) & 0xFFFF;  // 修订号位于高16位
    printf("This chip deviceID ID:0x%03X, revisionID ID:0x%03X\n",deviceID,revisionID);
    switch (deviceID) {
        case STM32F1_low_density_FamilyID:
            target_device.flash_dev_info                 = (flash_dev_t *)&STM32F10x_128_flash_dev,
            target_device.sector_info_length             = (sizeof(STM32F10x_128_flash_dev))/(sizeof(uint32_t)),
            target_device.flash_regions[0].start         = target_device.flash_dev_info->DevAdr,
            target_device.flash_regions[0].end           = target_device.flash_dev_info->DevAdr + target_device.flash_dev_info->szDev,
            target_device.flash_regions[0].flash_algo    = (program_target_t *) &STM32F10x_128_flash,
            printf("This is an STM32F1 low density series chip.Device ID:0x%03X\n",deviceID);
            break;
        case STM32F1_medium_density_FamilyID:
            target_device.flash_dev_info                 = (flash_dev_t *)&STM32F10x_512_flash_dev,
            target_device.sector_info_length             = (sizeof(STM32F10x_512_flash_dev))/(sizeof(uint32_t)),
            target_device.flash_regions[0].start         = target_device.flash_dev_info->DevAdr,
            target_device.flash_regions[0].end           = target_device.flash_dev_info->DevAdr + target_device.flash_dev_info->szDev,
            target_device.flash_regions[0].flash_algo    = (program_target_t *) &STM32F10x_512_flash,
            printf("This is an STM32F1 medium density series chip.Device ID:0x%03X\n",deviceID);
            break;
        case STM32F1_high_density_FamilyID:           
            target_device.flash_dev_info                 = (flash_dev_t *)&STM32F10x_1024_flash_dev,
            target_device.sector_info_length             = (sizeof(STM32F10x_1024_flash_dev))/(sizeof(uint32_t)),
            target_device.flash_regions[0].start         = target_device.flash_dev_info->DevAdr,
            target_device.flash_regions[0].end           = target_device.flash_dev_info->DevAdr + target_device.flash_dev_info->szDev,
            target_device.flash_regions[0].flash_algo    = (program_target_t *) &STM32F10x_1024_flash,
            printf("This is an STM32F1 high density series chip.Device ID:0x%03X\n",deviceID);
            break;
         case STM32G4_Category2_FamilyID:
         case STM32G4_Category3_FamilyID: 
         case STM32G4_Category4_FamilyID: 
            target_device.flash_dev_info                 = (flash_dev_t *)&STM32G4xx_512_flash_dev,
            target_device.sector_info_length             = (sizeof(STM32G4xx_512_flash_dev))/(sizeof(uint32_t)),
            target_device.flash_regions[0].start         = target_device.flash_dev_info->DevAdr,
            target_device.flash_regions[0].end           = target_device.flash_dev_info->DevAdr + target_device.flash_dev_info->szDev,
            target_device.flash_regions[0].flash_algo    = (program_target_t *) &STM32G4xx_512_flash,              
            printf("This is an STM32G4 density series chip.Device ID:0x%03X\n",deviceID);
            break;
         case STM32F405x07x15x17_FamilyID:
         case STM32F401xBxC_FamilyID: 
         case STM32F401xDxE_FamilyID: 
         case STM32F413423_FamilyID:
         case STM32F411xCxE_FamilyID:
         case STM32F42x3x_FamilyID:
            target_device.flash_dev_info                 = (flash_dev_t *)&STM32F4xx_1024_flash_dev,
            target_device.sector_info_length             = (sizeof(STM32F4xx_1024_flash_dev))/(sizeof(uint32_t)),
            target_device.flash_regions[0].start         = target_device.flash_dev_info->DevAdr,
            target_device.flash_regions[0].end           = target_device.flash_dev_info->DevAdr + target_device.flash_dev_info->szDev,
            target_device.flash_regions[0].flash_algo    = (program_target_t *) &STM32F4xx_1024_flash,
            printf("This is an STM32F4 high density series chip.Device ID:0x%03X\n",deviceID);
            break;
         case STM32H7_FamilyID:
            target_device.flash_dev_info                 = (flash_dev_t *)&STM32H7x_2048_flash_dev,
            target_device.sector_info_length             = (sizeof(STM32H7x_2048_flash_dev))/(sizeof(uint32_t)),
            target_device.flash_regions[0].start         = target_device.flash_dev_info->DevAdr,
            target_device.flash_regions[0].end           = target_device.flash_dev_info->DevAdr + target_device.flash_dev_info->szDev,
            target_device.flash_regions[0].flash_algo    = (program_target_t *) &STM32H7x_2048_flash,
            printf("This is an STM32H7 series chip.Device ID:0x%03X\n",deviceID);
            break;


         case GD32E50x_512_FamilyID:
            target_device.flash_dev_info                 = (flash_dev_t *)&GD32E50x_512_flash_dev,
            target_device.sector_info_length             = (sizeof(GD32E50x_512_flash_dev))/(sizeof(uint32_t)),
            target_device.flash_regions[0].start         = target_device.flash_dev_info->DevAdr,
            target_device.flash_regions[0].end           = target_device.flash_dev_info->DevAdr + target_device.flash_dev_info->szDev,
            target_device.flash_regions[0].flash_algo    = (program_target_t *) &GD32E50x_512_flash,
            printf("This is an GD32E50x series chip.Device ID:0x%03X\n",deviceID);
            break;
          case  GD32F303_HD_FamilyID:
            target_device.flash_dev_info                 = (flash_dev_t *)&GD32F30x_HD_flash_dev,
            target_device.sector_info_length             = (sizeof(GD32F30x_HD_flash_dev))/(sizeof(uint32_t)),
            target_device.flash_regions[0].start         = target_device.flash_dev_info->DevAdr,
            target_device.flash_regions[0].end           = target_device.flash_dev_info->DevAdr + target_device.flash_dev_info->szDev,
            target_device.flash_regions[0].flash_algo    = (program_target_t *) &GD32F30x_HD_flash,
            printf("This is an GD32F303 series chip.Device ID:0x%03X\n",deviceID);
          break;
        // 添加更多设备ID判断
        default:
            break;
    }    

    swd_set_reset_connect(CONNECT_UNDER_RESET);
    return family_id;
}

uint8_t target_set_state(target_state_t state)
{
    return swd_set_target_state_sw(state);
}

void swd_set_target_reset(uint8_t asserted)
{
    (asserted) ? PIN_nRESET_OUT(0) : PIN_nRESET_OUT(1);
}

uint32_t target_get_apsel()
{
    return 0;
}


