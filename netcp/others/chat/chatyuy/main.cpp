#include <sys/socket.h>
#include <netinet/in.h>
#include <thread>
#include "socket.h"

sockaddr_in make_ip_address(const std::string& ip_address, int port){
	// Dirección del socket local
  sockaddr_in address{};    // Así se inicializa a 0, como se recomienda
  address.sin_family = AF_INET;    // Pues el socket es de dominio AF_INET
  if( ip_address == "")
    address.sin_addr.s_addr = htonl ( INADDR_ANY);
  else
    inet_aton( ip_address.c_str(), &address.sin_addr);
  address.sin_port = htons( port);
  return address;
}
void Receptor(){
 //1.-crear socket local
  sockaddr_in local_address2 {};
  local_address2 = make_ip_address("", 55000);
  //2.-asignar direccion al socket local "bind()"
  Socket socket_local2( local_address2); //SOCKET LOCAL, constructor hace bind
  //3.-bucle
    //recibir linea del socket remoto "recvfrom()"
  sockaddr_in remote_address2{};    // Porque se recomienda inicializar a 0

  while (true) {
  Message message2;
  socket_local2.receive_from( message2, remote_address2);
    //mostrar en pantalla
  char* remote_ip = inet_ntoa(remote_address2.sin_addr);
  int remote_port = ntohs(remote_address2.sin_port);

  std::cout << "El sistema " << remote_ip << ":" << remote_port <<
" envió el mensaje '" << message2.text.data() << "'\n";
  std::cout.flush();
  }
}
int main( int argc, char** arcv) {
  std::thread receptor_thread( &Receptor);


  sockaddr_in local_address {};
  local_address = make_ip_address( "", 0);

  Socket socket_local( local_address); //SOCKET LOCAL
  //1.-Preparar direccion del socket remoto
  //int puerto = 51000;
  //std::string direccion ( INADDR_LOOPBACK);	//falta direccion
  sockaddr_in remote_address{};
  remote_address = make_ip_address( "83.47.18.5" , 51000);
  //inet_aton( direccion.str, &remote_address.sin_addr);
  //2.-Abrir archivo "prueba.txt"
  //3.-Guardar datos
  //4.-BUcle hasta fin de datos
    //Leer linea
    //enviarla al socket remoto "sendto()"
    //POR AHORA SOLO UN MENSAJE
  while( !std::cin.eof()) {
  Message message;
  std::string message_text=" ";
  message_text.copy(message.text.data(), message.text.size() - 1, 0);
  message.text[message_text.size()] = '\0';
  std::getline(std::cin, message_text);
  message_text.copy(message.text.data(), message.text.size() - 1, 0);
  socket_local.send_to( message, remote_address); //remote address
  std::cin.clear();
  }
  //5.-Liberar recursos
  receptor_thread.join();
	//Socket que envia
  return 0;
}
