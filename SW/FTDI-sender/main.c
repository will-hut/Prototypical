/*
	Simple example to read a large amount of data from a BM device.
	Device must have bitbang capabilities to enable this to work	

	To build use the following gcc statement 
	(assuming you have the d2xx library in the /usr/local/lib directory).
	gcc -o largeread main.c -L. -lftd2xx -Wl,-rpath /usr/local/lib
*/

#include <stdio.h>
#include <stdlib.h>
#include "ftd2xx.h"

int main(int argc, char** argv) {

    FT_HANDLE handle;
	
    // check how many FTDI devices are attached to this PC
    unsigned long deviceCount = 0;
    if(FT_CreateDeviceInfoList(&deviceCount) != FT_OK) {
        printf("Unable to query devices. Exiting.\r\n");
        return 1;
    }

    // get a list of information about each FTDI device
    FT_DEVICE_LIST_INFO_NODE* deviceInfo = (FT_DEVICE_LIST_INFO_NODE*) malloc(sizeof(FT_DEVICE_LIST_INFO_NODE) * deviceCount);
    if(FT_GetDeviceInfoList(deviceInfo, &deviceCount) != FT_OK) {
        printf("Unable to get the list of info. Exiting.\r\n");
        return 1;
    }

    // print the list of information
    for(unsigned long i = 0; i < deviceCount; i++) {
		
        printf("Device = %d\r\n", i);
        printf("Flags = 0x%X\r\n", deviceInfo[i].Flags);
        printf("Type = 0x%X\r\n", deviceInfo[i].Type);
        printf("ID = 0x%X\r\n", deviceInfo[i].ID);
        printf("LocId = 0x%X\r\n", deviceInfo[i].LocId);
        printf("SN = %s\r\n", deviceInfo[i].SerialNumber);
        printf("Description = %s\r\n", deviceInfo[i].Description);
        printf("Handle = 0x%X\r\n", deviceInfo[i].ftHandle);
        printf("\r\n");

        // connect to the device with SN "FT73ZHPE"
        if(strcmp(deviceInfo[i].SerialNumber, "FT73ZHPEA") == 0) {
			
            if (FT_OpenEx(deviceInfo[i].SerialNumber, FT_OPEN_BY_SERIAL_NUMBER, &handle) == FT_OK &&
                FT_SetBitMode(handle, 0xFF, 0x40) == FT_OK &&
                FT_SetLatencyTimer(handle, 2) == FT_OK &&
                FT_SetUSBParameters(handle, 65536, 65536) == FT_OK &&
                FT_SetFlowControl(handle, FT_FLOW_RTS_CTS, 0, 0) == FT_OK &&
                FT_Purge(handle, FT_PURGE_RX | FT_PURGE_TX) == FT_OK &&
                FT_SetTimeouts(handle, 1000, 1000) == FT_OK) {
				// connected and configured successfully

				printf("Connected to FTDI device.\r\n");
					
                // write to FPGA
                char txBuffer[4096] = { 0 };
				txBuffer[4095] = 0x00;

				unsigned long byteCount = 0;
				for(int i = 0; i < 4096; i++){
					txBuffer[4095] = i % 256;
					if(FT_Write(handle, txBuffer, 4096, &byteCount) != FT_OK) {
						printf("Error while writing to the device. Exiting.\r\n");
						return 1;
					}
				}
				printf("Successfully wrote to device! Exiting.\r\n");
                return 0;
				
            } else {
				
                // unable to connect or configure
                printf("Unable to connect to or configure the device. Exiting.\r\n");
                return 1;
				
            }
			
        }
		
    }

    return 0;

}