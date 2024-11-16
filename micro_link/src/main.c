/*
 * Copyright (c) 2022-2023 HPMicro
 *
 * SPDX-License-Identifier: BSD-3-Clause
 *
 */
/* FreeRTOS kernel includes. */
#include "FreeRTOS.h"
#include "task.h"
#include "usb_osal.h"
#include "hpm_ppor_drv.h"
#include <stdio.h>
#include "board.h"
#include "hpm_gpio_drv.h"
#include "usb_config.h"
#include "cdc_acm_msc_dap.h"
#include "vfs_manager.h"
#include "ymodem_send_file.h"
#include "hpm_romapi.h"
#include "ota_api.h"

#define NUM_OF_NIST_KEYS          16


#define LED_FLASH_PERIOD_IN_MS 50
#define USB_BUS_ID 0

extern void uartx_preinit(void);
extern void usbd_msc_init(void);

#define task1_PRIORITY    (configMAX_PRIORITIES - 8U)
#define task2_PRIORITY    (configMAX_PRIORITIES - 7U)
#define task3_PRIORITY    (configMAX_PRIORITIES - 6U)
#define task4_PRIORITY    (configMAX_PRIORITIES - 5U)
static volatile uint8_t ledUsbInActivity = 0;
static volatile uint8_t ledUsbOutActivity = 0;
static void task1(void *pvParameters)
{
    (void)pvParameters;
    chry_dap_handle(USB_BUS_ID);
}

static void task2(void *pvParameters)
{
    (void)pvParameters;
    chry_dap_usb2uart_handle(USB_BUS_ID);
}

static void task3(void *pvParameters)
{
    (void)pvParameters;
    while(1){
        vfs_mngr_periodic(90);
        vTaskDelay(90);
    }
}

static void task4(void *pvParameters)
{
    (void)pvParameters;
    while(1){
        ymodem_send_task(&tYmodemSend);
        vTaskDelay(1);
    }
}

void board_led_toggle(void)
{
    static uint8_t usb_in_led_value = BOARD_LED_OFF_LEVEL;
    static uint8_t usb_out_led_value = BOARD_LED_OFF_LEVEL;
    if(ledUsbInActivity){
         usb_in_led_value = BOARD_LED_ON_LEVEL == usb_in_led_value ? BOARD_LED_OFF_LEVEL : BOARD_LED_ON_LEVEL;
         gpio_write_pin(BOARD_LED_USB_IN_GPIO_CTRL, BOARD_LED_USB_IN_GPIO_INDEX, BOARD_LED_USB_IN_GPIO_PIN,usb_in_led_value);
         if(usb_in_led_value == BOARD_LED_OFF_LEVEL){
             ledUsbInActivity = 0;
         }
    }else{
         gpio_write_pin(BOARD_LED_USB_IN_GPIO_CTRL, BOARD_LED_USB_IN_GPIO_INDEX, BOARD_LED_USB_IN_GPIO_PIN,BOARD_LED_OFF_LEVEL);
    }

    if(ledUsbOutActivity){
         usb_out_led_value = BOARD_LED_ON_LEVEL == usb_out_led_value ? BOARD_LED_OFF_LEVEL : BOARD_LED_ON_LEVEL;
         gpio_write_pin(BOARD_LED_USB_OUT_GPIO_CTRL, BOARD_LED_USB_OUT_GPIO_INDEX, BOARD_LED_USB_OUT_GPIO_PIN,usb_out_led_value);
         if(usb_out_led_value == BOARD_LED_OFF_LEVEL){
             ledUsbOutActivity = 0;
         }
    }else{
         gpio_write_pin(BOARD_LED_USB_OUT_GPIO_CTRL, BOARD_LED_USB_OUT_GPIO_INDEX, BOARD_LED_USB_OUT_GPIO_PIN,BOARD_LED_OFF_LEVEL);
    }

}

void led_usb_in_activity(void)
{
    ledUsbInActivity = 1;
    return;
}

void led_usb_out_activity(void)
{
    ledUsbOutActivity = 1;
    return;
}


int main(void)
{

    board_init();
    ota_board_flash_init();
    board_init_led_pins();
    board_init_usb_pins();
    board_init_gpio_pins();
    gpio_set_pin_input(BOARD_APP_GPIO_CTRL, BOARD_APP_GPIO_INDEX, BOARD_APP_GPIO_PIN);
    intc_set_irq_priority(CONFIG_HPM_USBD_IRQn, 2);
    board_timer_create(LED_FLASH_PERIOD_IN_MS, board_led_toggle);
    uartx_preinit();
    usbd_msc_init();
    vfs_mngr_fs_enable(1);
    chry_dap_init(USB_BUS_ID, CONFIG_HPM_USBD_BASE);

    if (usb_osal_thread_create("task1", 1024U, task1_PRIORITY, task1, NULL) == NULL) {
        printf("Task1 creation failed!.\n");
        for (;;) {
            ;
        }
    }
    if (usb_osal_thread_create("task2", 1024U, task2_PRIORITY, task2, NULL) == NULL) {
        printf("Task2 creation failed!.\n");
        for (;;) {
            ;
        }
    }
    if (usb_osal_thread_create("task3", 1024U, task3_PRIORITY, task3, NULL) == NULL) {
        printf("Task3 creation failed!.\n");
        for (;;) {
            ;
        }
    }
    if (usb_osal_thread_create("task4", 1024U, task4_PRIORITY, task4, NULL) == NULL) {
        printf("Task4 creation failed!.\n");
        for (;;) {
            ;
        }
    }
    vTaskStartScheduler();
    for (;;) {
        ;
    }
    return 0;
}

void SystemReset(void)
{
    ppor_sw_reset(HPM_PPOR, 10);
}

