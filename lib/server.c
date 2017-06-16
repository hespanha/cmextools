/*
  Copyright 2012-2017 Joao Hespanha

  This file is part of Tencalc.

  TensCalc is free software: you can redistribute it and/or modify it
  under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  TensCalc is distributed in the hope that it will be useful, but
  WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
  General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with TensCalc.  If not, see <http://www.gnu.org/licenses/>.
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

	    
	    
