#include <sys/socket.h>
#include <arpa/inet.h>
#include <netinet/in.h>
#include <iostream>
#include <string.h>
#include <string>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <array>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <system_error>
#include <cerrno>
#include <cstring>

struct Message
{
  std::array<char, 1024> text;
};

sockaddr_in make_ip_address(const std::string& ip_address, int port)
{
  sockaddr_in address{};
  address.sin_family = AF_INET;
  // Asignar a mi extremo receptor.
  if (ip_address == "")
  {
    address.sin_addr.s_addr = htonl(INADDR_ANY);
    address.sin_port = htons(port);
  }
  // Asignar a un destinatario.
  else
  {
    // assert((1 <= port) && (port <= 65535));
    address.sin_port = htons(port);
    inet_aton(ip_address.c_str(), &address.sin_addr);
  }
  return address;
}
