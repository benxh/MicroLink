#ifndef __OTA_API_H
#define __OTA_API_H

#include <stdbool.h>
#include <stdint.h>
#include <string.h>
#include "board.h"
#include "flash_map.h"

#define USER_UPGREAD_FLAG_MAGIC   (0xbeaf5aa5)
#define BOARD_DEVICE_ID           (0x6750)

/*ota flag structure*/
typedef struct
{
    uint32_t magic;
    uint32_t device;
    uint32_t len;
    uint32_t checksum;
} user_fota_header_t;

void ota_board_flash_init(void);

void ota_board_complete_reset(void);

void board_flash_read(uint32_t addr, void* buffer, uint32_t len);

uint32_t ota_board_flash_size(uint8_t ota_index);

void ota_board_flash_write(uint32_t addr, void const* src, uint32_t len);

bool ota_board_auto_write(void const* src, uint32_t len);

int ota_fota_flash_checksum(uint32_t addr, uint32_t len, uint32_t* checksum);

bool ota_board_auto_checksum(void);

void ota_board_app_jump(uint8_t ota_index);

uint8_t ota_check_current_otaindex(void);

void board_flash_erase(uint32_t addr);

void board_flash_write(uint32_t addr, void const* src, uint32_t len);
#endif //__OTA_API_H