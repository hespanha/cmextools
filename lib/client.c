/*
  This file is part of Tencalc.

  Copyright (C) 2012-21 The Regents of the University of California
  (author: Dr. Joao Hespanha).  All rights reserved.
*/

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>

/* CLIENT SIDE */

int connect2server(char *serverIP,int port)
{
  int sockfd;
  struct sockaddr_in serv_addr;
  struct hostent *server;

  sockfd = socket(AF_INET, SOCK_STREAM, 0);
  if (sockfd < 0) {
    fprintf(stderr,"client: ERROR opening socket");
    return sockfd;
  }
  server = gethostbyname(serverIP);
  if (server == NULL) {
    fprintf(stderr,"client: ERROR, no such host\n");
    return -1;
  }
  bzero((char *) &serv_addr, sizeof(serv_addr));
  serv_addr.sin_family = AF_INET;
  bcopy((char *)server->h_addr,
	(char *)&serv_addr.sin_addr.s_addr,
	server->h_length);
  serv_addr.sin_port = htons(port);
  if (connect(sockfd,(struct sockaddr *) &serv_addr,sizeof(serv_addr)) < 0) {
    fprintf(stderr,"ERROR connecting");
    return -1;
  }
  return sockfd;
}
