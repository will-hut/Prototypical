#include <sys/types.h>
#include <sys/socket.h>
#include <sys/un.h>
#include <sys/unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include "ftd2xx.h"


#define SOCKET_NAME "screen.socket"
#define SCREEN_SIZE 128*128*3


int main()
{

    FT_HANDLE ftdi_handle;

    int sock_server, sock_client;
    struct sockaddr_un server_addr;
    char pixel_buf[SCREEN_SIZE];

    // OPEN FTDI DEVICE ==============================================================

    // check how many FTDI devices are attached to this PC
    unsigned int device_count = 0;
    if(FT_CreateDeviceInfoList(&device_count) != FT_OK) {
        printf("Unable to query devices. Exiting.\n");
        exit(1);
    }

    // Make sure there are devices connected
    if(device_count == 0) {
        printf("No FTDI devices detected. Exiting.\n");
        exit(1);
    }

    // Try to open the device with the description "Prototypical"
    if(FT_OpenEx("Prototypical A", FT_OPEN_BY_DESCRIPTION, &ftdi_handle) != FT_OK){
        printf("Unable to find the device. Exiting.\n");
        return 1;
    }

    // Configure device to work in FIFO mode
    if(
        FT_SetBitMode(ftdi_handle, 0xFF, 0x40) != FT_OK ||
        FT_SetLatencyTimer(ftdi_handle, 2) != FT_OK ||
        FT_SetUSBParameters(ftdi_handle, 65536, 65536) != FT_OK ||
        FT_SetFlowControl(ftdi_handle, FT_FLOW_RTS_CTS, 0, 0) != FT_OK ||
        FT_Purge(ftdi_handle, FT_PURGE_RX | FT_PURGE_TX) != FT_OK ||
        FT_SetTimeouts(ftdi_handle, 50, 50) != FT_OK
    ){
        printf("Unable to configure device. Exiting.\n");
        FT_Close(ftdi_handle);
        return 1;
    }

    printf("Successfully connected to FTDI device\n");



    // OPEN SERVER SOCKET ===========================================================

    // Clean up old server socket if it exists
    if (access(SOCKET_NAME, F_OK) != -1) {
        if (unlink(SOCKET_NAME) == -1) {
            perror("unlink");
            exit(1);
        }
    }

    // create server socket
    sock_server = socket(AF_UNIX, SOCK_STREAM, 0);
    if (sock_server < 0) {
        perror("opening stream socket");
        exit(1);
    }

    // bind socket to file descriptor
    server_addr.sun_family = AF_UNIX;
    strcpy(server_addr.sun_path, SOCKET_NAME);
    if (bind(sock_server, (struct sockaddr *) &server_addr, sizeof(struct sockaddr_un))) {
        perror("binding stream socket");
        exit(1);
    }

    printf("Socket created successfully.\n");
    printf("Socket has name %s\n", server_addr.sun_path);
    
    // begin infinitely listening on socket
    listen(sock_server, 1);
    while (1) {

        // try to accept connection to client
        if ((sock_client = accept(sock_server, NULL, NULL)) == -1) {
            perror("accept");
            close(sock_server);
            unlink(SOCKET_NAME);
            FT_Close(ftdi_handle);
            exit(1);
        }

        printf("Client connected.\n");

        while(1) {
            int bytes_received = recv(sock_client, pixel_buf, sizeof(pixel_buf), MSG_WAITALL);
            
            if (bytes_received == -1) {
                perror("recv");
                close(sock_client);
                close(sock_server);
                unlink(SOCKET_NAME);
                FT_Close(ftdi_handle);
                exit(1);
            } else if (bytes_received == 0) {
                // Client disconnected
                printf("Client disconnected.\n");
                break;
            } else {
                unsigned int byteCount = 0;
                if(FT_Write(ftdi_handle, pixel_buf, sizeof(pixel_buf), &byteCount) != FT_OK || byteCount != SCREEN_SIZE) {
                    printf("FT_Write unsuccessful.\n");
                }
            }
        }

        close(sock_client);
    }
    close(sock_server);
    unlink(SOCKET_NAME);
    FT_Close(ftdi_handle);
}
