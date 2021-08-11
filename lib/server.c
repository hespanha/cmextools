/*
  This file is part of Tencalc.

  Copyright (C) 2012-21 The Regents of the University of California
  (author: Dr. Joao Hespanha).  All rights reserved.
*/

#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/stat.h>
#include <netinet/in.h>

void error(const char *msg)
{
    perror(msg);
    exit(1);
}

/* SERVER SIDE */

int initServer(int port)
{
  // Disable buffering on stdout
  setbuf(stdout, NULL);

  int sockfd;
  struct sockaddr_in serv_addr;
  sockfd = socket(AF_INET, SOCK_STREAM, 0);
  if (sockfd < 0)
    error("server: ERROR opening socket");
  bzero((char *) &serv_addr, sizeof(serv_addr));
  serv_addr.sin_family = AF_INET;
  serv_addr.sin_addr.s_addr = INADDR_ANY;
  serv_addr.sin_port = htons(port);
  if (bind(sockfd,
	   (struct sockaddr *) &serv_addr,
	   sizeof(serv_addr)) < 0)
    error("server: ERROR on binding");
  listen(sockfd,5);

  return sockfd;
}

int wait4client(int sockfd)
{
  struct sockaddr_in cli_addr;
  socklen_t clilen = sizeof(cli_addr);
  int newsockfd = accept(sockfd,
			 (struct sockaddr *) &cli_addr,
			 &clilen);
  if (newsockfd < 0)
    error("server: ERROR on accept");
  return newsockfd;
}
