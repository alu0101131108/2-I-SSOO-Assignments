#include "Socket.cpp"

int protected_main(int argc, char** argv)
{
  sockaddr_in local_address = make_ip_address("", 55000);
  sockaddr_in remote_address = make_ip_address("", 0);
  Socket local(local_address);

  // Recepción del mensaje.
  while(true)
  {
    Message message_in;
    local.recieve_from(message_in, remote_address);
    char* remote_ip = inet_ntoa(remote_address.sin_addr);
    int remote_port = ntohs(remote_address.sin_port);
    std::cout << ">>El sistema " << remote_ip << ":" << remote_port << " envió el mensaje:\n" << message_in.text.data() << ">>Fin del mensaje.\n";
  }
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
    std::cerr << "NetcpRecieve" << ": memoria insuficiente.\n";
    return 1;
  }
  catch(std::system_error &e)
  {
    std::cerr << "NetcpRecieve"  << " " << e.what() << '\n';
    return 2;
  }
  catch(...)
  {
    std::cerr << "Error desconocido\n";
    return 99;
  }
}
