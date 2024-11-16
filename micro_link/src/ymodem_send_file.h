#ifndef APPLICATIONS_CHECK_AGENT_XMODEM_SEND_H_
#define APPLICATIONS_CHECK_AGENT_XMODEM_SEND_H_
#include "wl_ymodem.h"
#include <stdbool.h>
typedef struct ymodem_send_t {
    ymodem_t     parent;
    char         chFileName[32];
    uint32_t     wFileSize;
    uint32_t     wOffSet;
} ymodem_send_t;
extern ymodem_send_t tYmodemSend;
extern bool    bYmomdemIsinit;
void ymomdem_usb_in_queue(const uint8_t *pchBuffer, uint32_t hwSize);
void ymodem_send_task(ymodem_send_t *ptObj);
void ymomdem_uart_in_queue(const uint8_t *pchBuffer, uint32_t hwSize);
ymodem_send_t *ymodem_send_init(ymodem_send_t *ptObj);
ymodem_send_t *ymodem_send_uninit(ymodem_send_t *ptObj);
#endif /* APPLICATIONS_CHECK_AGENT_XMODEM_H_ */




