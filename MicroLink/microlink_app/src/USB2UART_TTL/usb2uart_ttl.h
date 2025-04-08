#ifndef HSLINK_PRO_USB2UART_TTL_H
#define HSLINK_PRO_USB2UART_TTL_H
#include "usb_configuration.h"
#include "microboot.h"
#include "usb2uart.h"

#if 0
typedef struct
{
    SIG_SLOT_OBJ;
    uint8_t Byte;
    uint16_t hwLen;
}uart_data_msg_t;
#endif

#ifdef USE_UART_TTL

signals(uart_ttl_rx,uart_data_msg_t *ptThis,
      args(              
            uint8_t *pchByte,
            uint16_t hwLen
          ));

extern uart_data_msg_t  tUartMsgObj_uart_ttl;
extern volatile uint8_t config_uart_transfer_uart_ttl;
extern volatile uint8_t usbrx_idle_flag_uart_ttl;
extern volatile uint8_t usbtx_idle_flag_uart_ttl;
extern volatile uint8_t uarttx_idle_flag_uart_ttl;
extern volatile struct cdc_line_coding g_cdc_lincoding_ep2_uart_ttl;
extern volatile uint8_t config_uart_uart_ttl;

extern USB_NOCACHE_RAM_SECTION USB_MEM_ALIGNX uint8_t cdc_tmpbuffer_ep2_uart_ttl[DAP_PACKET_SIZE];

void uartx_preinit_uart_ttl(void);
void usb2uart_handler_uart_ttl(void);
void chry_dap_usb2uart_handle_uart_ttl(void);

#endif

#endif //HSLINK_PRO_USB2UART_TTL_H
