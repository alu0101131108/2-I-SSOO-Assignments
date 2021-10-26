#include "imports.hpp"

int main(int argc, char** argv)
{
  int fd, r = -1;
  char buf[1024];
  if((fd = open("/home/sebas/ULL/2º/SSOO/Practicas/Netcp/prueba.txt", 0000)) < 0)
    std::cerr << "fichRead.cpp: Falló open(). " << strerror(fd) << '\n';
  else
    while((r = read(fd, &buf, sizeof(buf) - 1)) > 0)
    {
        buf[r] = 0x00;
        std::cout << buf;
    }

  int close(fd);

  return 0;
}
