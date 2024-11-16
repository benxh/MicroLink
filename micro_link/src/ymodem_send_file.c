#include "ymodem_send_file.h"
#include "cdc_acm_msc_dap.h"
#include "FreeRTOS.h"
#include "task.h"
#undef this
#define this        (*ptThis)

ymodem_send_t tYmodemSend;
bool    bYmomdemIsinit = false,bYmomdemIsFinsh = false;
static uint8_t s_chBuffer[1024] ;

static uint8_t ymodem_usb_ringbuffer[4096];
chry_ringbuffer_t tYmodemUSBInQueue;

static uint8_t ymodem_uart_ringbuffer[128];
chry_ringbuffer_t tYmodemUartInQueue;

static uint16_t ymodem_send_file_name(ymodem_t *ptObj, uint8_t *pchBuffer, uint16_t hwSize)
{
    ymodem_send_t *(ptThis) = (ymodem_send_t *)ptObj;
    if(this.wOffSet == this.wFileSize){
        this.wOffSet = 0;
        return 0;
    }
    sprintf((char *)pchBuffer, "%s%c%d", this.chFileName, '\0', this.wFileSize);
    memset(this.chFileName, 0,sizeof(this.chFileName));
    return hwSize;
}

static uint16_t ymodem_send_file_data(ymodem_t *ptObj, uint8_t *pchBuffer, uint16_t hwSize)
{
    ymodem_send_t *(ptThis) = (ymodem_send_t *)ptObj;
    if(this.wFileSize - this.wOffSet < 1024){
        do{        
            if (chry_ringbuffer_get_used(&tYmodemUSBInQueue) >= (this.wFileSize - this.wOffSet)) {
                 chry_ringbuffer_read(&tYmodemUSBInQueue, pchBuffer, (this.wFileSize - this.wOffSet));
                 hwSize = (this.wFileSize - this.wOffSet);
                 this.wOffSet = this.wFileSize;
                 break;
            }else{
                 vTaskDelay(1);      
            }
        }while(1); 
    }else{
        do{
            if (chry_ringbuffer_get_used(&tYmodemUSBInQueue) >= 1024) {
                 chry_ringbuffer_read(&tYmodemUSBInQueue, pchBuffer, 1024);
                 hwSize = 1024;
                 this.wOffSet += 1024;
                 break;
            } else{
                 vTaskDelay(1);                 
            }
        }while(1); 
    }

    return hwSize;
}

static uint16_t ymodem_read_data(ymodem_t *ptObj, uint8_t* pchByte, uint16_t hwSize)
{

    return chry_ringbuffer_read(&tYmodemUartInQueue, pchByte, hwSize);
}

static uint16_t ymodem_write_data(ymodem_t *ptObj, uint8_t* pchByte, uint16_t hwSize)
{
    chry_ringbuffer_write(&g_usbrx, pchByte, hwSize);
    chry_ringbuffer_write(&g_uartrx, pchByte, hwSize);
    if ((semaphore_acm_tx_done != NULL)) {
        int ret = usb_osal_sem_give(semaphore_acm_tx_done);
        if (ret != 0) {
            USB_LOG_ERR("usb_osal_sem_give error. Have you select DTR to enable the demo to send message to host?\r\n");
        }
    }
    return hwSize;
}

ymodem_send_t *ymodem_send_init(ymodem_send_t *ptObj)
{
    ymodem_send_t *(ptThis) = ptObj;
    bYmomdemIsinit = true;
    this.wOffSet = 0;

    chry_ringbuffer_init(&tYmodemUSBInQueue, ymodem_usb_ringbuffer,sizeof(ymodem_usb_ringbuffer));
    chry_ringbuffer_init(&tYmodemUartInQueue, ymodem_uart_ringbuffer,sizeof(ymodem_uart_ringbuffer));

    ymodem_ops_t s_tOps = {
        .pchBuffer = s_chBuffer,
        .hwSize = sizeof(s_chBuffer),
        .fnOnFileData = ymodem_send_file_data,
        .fnOnFilePath = ymodem_send_file_name,
        .fnReadData = ymodem_read_data,
        .fnWriteData = ymodem_write_data,
    };
    bYmomdemIsFinsh = false;
    ymodem_init(&this.parent, &s_tOps);
    ymodem_write_data(&this.parent,(uint8_t*)"ry\r\n",strlen("ry\r\n"));
    return ptObj;
}

ymodem_send_t *ymodem_send_uninit(ymodem_send_t *ptObj)
{
    ymodem_send_t *(ptThis) = ptObj;
    bYmomdemIsinit = false;
    return ptObj;
}

void ymodem_transfer_state(ymodem_t *ptObj, ymodem_state_t tState)
{
    if(tState == STATE_FINSH){
        bYmomdemIsFinsh = true;
        ymodem_write_data(ptObj,(uint8_t*)"reboot\r\n",strlen("reboot\r\n"));
    }
}

void ymodem_send_task(ymodem_send_t *ptObj)
{
    ymodem_send_t *(ptThis) = ptObj;
    if(bYmomdemIsinit && bYmomdemIsFinsh == false){
        ymodem_send(&this.parent);
    }
}

void ymomdem_usb_in_queue(const uint8_t *pchBuffer, uint32_t hwSize)
{
    do{
        if (chry_ringbuffer_get_free(&tYmodemUSBInQueue) >= hwSize) {
             chry_ringbuffer_write(&tYmodemUSBInQueue, (void *)pchBuffer, hwSize);
             break;
        } else{
             vTaskDelay(1);                 
        }
    }while(1); 
}

void ymomdem_uart_in_queue(const uint8_t *pchBuffer, uint32_t hwSize)
{
    if(bYmomdemIsinit){
        if (chry_ringbuffer_get_free(&tYmodemUartInQueue) >= hwSize) {
             chry_ringbuffer_write(&tYmodemUartInQueue, (void *)pchBuffer, hwSize);
        }
    }
}
