#include "Socket.cpp"

int protected_main(int argc, char** argv)
{
  sockaddr_in local_address = make_ip_address("", 0);
  sockaddr_in remote_address = make_ip_address("", 51000);
  Socket local(local_address);

  int fd, bytes_read;
  std::array<char, 1024> buf;
  Message message_out;
  // Apertura del fichero a enviar.
  if((fd = open("/home/sebas/ULL/2º/ssoo/practicas/netcp/data/prueba.txt", 0000)) < 0)
    throw std::system_error(errno, std::system_category(), "No se pudo abrir el archivo.");
    // std::cerr << "fichRead.cpp: Falló open(). " << strerror(fd) << '\n';
  else
  // Envío por bloques de 1023 bytes.
    while((bytes_read = read(fd, &buf, sizeof(buf) - 1)) > 0)
    {
      buf[bytes_read] = 0x00;  // nose.
      message_out.text = buf;
      local.send_to(message_out, remote_address);
    }
  int close(fd);  // Cerrar el archivo.
  return 0;
}

int main(int argc, char** argv)
{
  try
  {
    return protected_main(argc, argv);
  }
  catch(std::bad_alloc &e)
  {
    std::cerr << "NetcpSend" << ": memoria insuficiente.\n";
    return 1;
  }
  catch(std::system_error& e)
  {
    std::cerr << "NetcpSend"  << " " << e.what() << '\n';
    return 2;
  }
  catch(...)
  {
    std::cerr << "Error desconocido\n";
    return 99;
  }
}
