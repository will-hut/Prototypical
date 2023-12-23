#include <sys/types.h>
#include <sys/socket.h>
#include <sys/un.h>
#include <sys/unistd.h>
#include <stdio.h>
#include <stdlib.h>

#define NAME "screen.socket"


main()
{
    int sock, msgsock;
    struct sockaddr_un server;
    char buf[1024];

    if (access(NAME, F_OK) != -1) {
        if (unlink(NAME) == -1) {
            perror("unlink");
            exit(1);
        }
    }

    // create server socket
    sock = socket(AF_UNIX, SOCK_STREAM, 0);
    if (sock < 0) {
        perror("opening stream socket");
        exit(1);
    }

    // bind socket to file descriptor
    server.sun_family = AF_UNIX;
    strcpy(server.sun_path, NAME);
    if (bind(sock, (struct sockaddr *) &server, sizeof(struct sockaddr_un))) {
        perror("binding stream socket");
        exit(1);
    }

    printf("Socket has name %s\n", server.sun_path);
    
    // begin infinitely listening on socket
    listen(sock, 1);
    while (1) {

        // try to accept connection to client
        if ((msgsock = accept(sock, NULL, NULL)) == -1) {
            perror("accept");
            close(sock);
            unlink(NAME);
            exit(1);
        }

        printf("Client connected...\n");

        while(1) {
            int bytes_received = recv(msgsock, buf, sizeof(buf), 0);
            
            if (bytes_received == -1) {
                perror("recv");
                close(msgsock);
                close(sock);
                unlink(NAME);
                exit(1);
            } else if (bytes_received == 0) {
                // Client disconnected
                printf("Client disconnected.\n");
                break;
            } else {
                printf("Received %i bytes.", bytes_received);
            }

        }

        close(msgsock);
    }
    close(sock);
    unlink(NAME);
}
