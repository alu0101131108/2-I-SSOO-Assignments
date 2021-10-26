#include "imports.hpp"

class Socket
{
  private:
    int fd_;

  public:
    Socket(const sockaddr_in& address)
    {
      fd_ = socket(AF_INET, SOCK_DGRAM, 0);
      if (fd_ < 0) // Error.
        throw std::system_error(errno, std::system_category(), "No se pudo enviar el mensaje.");
        // std::cerr << "Socket.hpp: Falló socket(). " << strerror(fd_) << '\n';
        // return 3;
      else
      {
        int result = bind(fd_, reinterpret_cast<const sockaddr*>(&address), sizeof(address));
        if (result < 0) // Error.
          throw std::system_error(errno, std::system_category(), "Falló bind().");
          // std::cerr << "Socket.hpp: Falló bind(). " << strerror(result) << '\n';
          // return 5;
      }
    }

    ~Socket()
    {
      int c = close(fd_);
      if (c != 0)
      {
        std::cerr << "Socket.hpp: Falló close(). " << strerror(c) << '\n';
        // throw std::system_error(errno, std::system_category(), "No se pudo cerrar el archivo.");
      }
    }

    void send_to(const Message & message, const sockaddr_in & address);
    void recieve_from(Message & message, sockaddr_in & address);
};
