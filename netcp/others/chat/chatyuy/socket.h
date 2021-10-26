#include <sys/types.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <netinet/in.h>
#include <cassert>
#include <iostream>
#include <string.h>
#include <string>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <array>
#include <cerrno>        // para errno
#include <cstring>        // para std::strerror()

struct Message {
    std::array<char, 1024> text;    // Igual que "char text[1024]"
};

class Socket
{
public:
    Socket(const sockaddr_in& address){
      int result = init(address);
      if( result > 0) {
        close( fd_);
      }
    }
    int init( const sockaddr_in& address) {
	fd_ = socket(AF_INET, SOCK_DGRAM, 0);
	if (fd_ < 0) {
	std::cerr << "no se pudo crear el socket: " <<    
	std::strerror(errno) << '\n';
	return 3;    // Error. Terminar con un valor diferente y > 0
	}
	// Asignar la dirección al socket local
	int result = bind(fd_, reinterpret_cast<const sockaddr*>(&address),
	      sizeof(address));
	if (result < 0) {
	std::cerr << "falló bind: " << result << '\n';
	return 5;    // Error. Terminar con un valor diferente y > 0
	}
    }    
    
    void send_to(const Message& message, const sockaddr_in& address){
	int result = sendto( fd_, &message, sizeof(message), 0,
	    reinterpret_cast<const sockaddr*>(&address),
	sizeof(address));
	if (result < 0) {
		std::cerr << "falló sendto: " << std::strerror(errno) << '\n';
		    // Error. Terminar con un valor diferente y > 0
	}	
    }
    void receive_from(Message& message, sockaddr_in& address){
      socklen_t src_len = sizeof(address);
	int result = recvfrom( fd_, &message, sizeof(message), 0, reinterpret_cast<sockaddr*>(&address), &src_len);
	if (result < 0) {
		std::cerr << "falló recvfrom: " << std::strerror(errno) << '\n';
	}
	}


    ~Socket(){
	    close(fd_);
    }

private:
    int fd_;
};

