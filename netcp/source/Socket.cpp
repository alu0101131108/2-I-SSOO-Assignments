#include "Socket.hpp"

void Socket::send_to(const Message & message, const sockaddr_in & address)
{
  int s = sendto(fd_, &message, sizeof(message), 0, reinterpret_cast<const sockaddr*>(&address), sizeof(address));
  if (s < 0)
    throw std::system_error(errno, std::system_category(), "No se pudo enviar el mensaje.");
    // std::cerr << "Socket.hpp: Falló sendto(). " << strerror(s) << '\n';
}

void Socket::recieve_from(Message & message, sockaddr_in & address)
{
  socklen_t src_len = sizeof(address);
  int result = recvfrom(fd_, &message, sizeof(message), 0, reinterpret_cast<sockaddr*>(&address), &src_len);
  if (result < 0)
    throw std::system_error(errno, std::system_category(), "No se pudo recibir el mensaje.");
    // std::cerr << "Socket.hpp: Falló recvfrom(). " << strerror(result) << '\n';
}
