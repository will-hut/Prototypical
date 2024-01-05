#include <sys/types.h>
#include <sys/socket.h>
#include <sys/stat.h>
#include <sys/un.h>
#include <sys/unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <libgen.h>
#include "ftd2xx.h"

#define SCREEN_BYTES 128*128*3
#define SCREEN_PIXELS 128*128



int main(int argc, char *argv[])
{

    FT_HANDLE ftdi_handle;

    int sock_server, sock_client;
    struct sockaddr_un server_addr;
    char recv_buf[SCREEN_BYTES];
    char ftdi_buf[SCREEN_BYTES];
    
    char *socket_name;

    if(argc > 1){
        socket_name = argv[1];
    } else {
        socket_name = "screen.socket";
    }

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
    if(FT_OpenEx("Prototypical", FT_OPEN_BY_DESCRIPTION, &ftdi_handle) != FT_OK){
        printf("Unable to find the device. Exiting.\n");
        exit(1);
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
    if (access(socket_name, F_OK) != -1) {
        if (unlink(socket_name) == -1) {
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
    strcpy(server_addr.sun_path, socket_name);
    if (bind(sock_server, (struct sockaddr *) &server_addr, sizeof(struct sockaddr_un))) {
        perror("binding stream socket");
        exit(1);
    }

    chmod(server_addr.sun_path, 0777);

    printf("Socket created successfully.\n");
    printf("Socket has name %s\n", server_addr.sun_path);
    
    // begin infinitely listening on socket
    listen(sock_server, 1);
    while (1) {

        // try to accept connection to client
        if ((sock_client = accept(sock_server, NULL, NULL)) == -1) {
            perror("accept");
            close(sock_server);
            unlink(socket_name);
            FT_Close(ftdi_handle);
            exit(1);
        }

        printf("Client connected.\n");

        while(1) {
            int bytes_received = recv(sock_client, recv_buf, sizeof(recv_buf), MSG_WAITALL);
            
            if (bytes_received == -1) {
                perror("recv");
                close(sock_client);
                close(sock_server);
                unlink(socket_name);
                FT_Close(ftdi_handle);
                exit(1);
            } else if (bytes_received == 0) {
                // Client disconnected
                printf("Client disconnected.\n");
                break;
            } else {

                int i = 0;
                while(i < SCREEN_BYTES){
                    ftdi_buf[i] = recv_buf[i] >> 1; //R
                    i++;
                    ftdi_buf[i] = recv_buf[i] >> 1; //G
                    i++;
                    ftdi_buf[i] = recv_buf[i] >> 2; //B
                    i++;
                }

                ftdi_buf[0] = ftdi_buf[0] | 0b10000000; // set MSB high to indicate start of frame

                unsigned int byteCount = 0;
                int result = FT_Write(ftdi_handle, ftdi_buf, sizeof(ftdi_buf), &byteCount);
                if(byteCount != SCREEN_BYTES){
                    printf("FT_Write timed out.\n");
                }

                if(result != FT_OK) {
                    printf("FT_Write unsuccessful. Error code ");
                    printf("%d\n", result);
                    exit(1);
                }
            }
        }

        close(sock_client);
    }
    close(sock_server);
    unlink(socket_name);
    FT_Close(ftdi_handle);
}
