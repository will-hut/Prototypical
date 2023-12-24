#include <sys/types.h>
#include <sys/socket.h>
#include <sys/un.h>
#include <sys/unistd.h>
#include <stdio.h>
#include <stdlib.h>

#define NAME "screen.socket"
#define SCREEN_SIZE 128*128*3


main()
{
    int sock_server, sock_client;
    struct sockaddr_un server_addr;
    char pixel_buf[SCREEN_SIZE];

    if (access(NAME, F_OK) != -1) {
        if (unlink(NAME) == -1) {
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
    strcpy(server_addr.sun_path, NAME);
    if (bind(sock_server, (struct sockaddr *) &server_addr, sizeof(struct sockaddr_un))) {
        perror("binding stream socket");
        exit(1);
    }

    printf("Socket has name %s\n", server_addr.sun_path);
    
    // begin infinitely listening on socket
    listen(sock_server, 1);
    while (1) {

        // try to accept connection to client
        if ((sock_client = accept(sock_server, NULL, NULL)) == -1) {
            perror("accept");
            close(sock_server);
            unlink(NAME);
            exit(1);
        }

        printf("Client connected...\n");

        while(1) {
            int bytes_received = recv(sock_client, pixel_buf, sizeof(pixel_buf), MSG_WAITALL);
            
            if (bytes_received == -1) {
                perror("recv");
                close(sock_client);
                close(sock_server);
                unlink(NAME);
                exit(1);
            } else if (bytes_received == 0) {
                // Client disconnected
                printf("Client disconnected.\n");
                break;
            } else {
                printf("Received %i bytes.\n", bytes_received);
            }

        }

        close(sock_client);
    }
    close(sock_server);
    unlink(NAME);
}
