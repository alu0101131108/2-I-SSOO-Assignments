#!/bin/bash
# sysinfo - Un script que informa del estado del sistema.

### Constantes
TITLE="Información del sistema para $HOSTNAME"
RIGHT_NOW=$(date +"%x %r%Z")
TIME_STAMP="Actualizada el $RIGHT_NOW por $USER"
USER_ID=$(id -u)
PROGNAME="sysinfo_page.sh"

### Opciones por defecto.
interactive=
filename=~/Escritorio/sysinfo.txt

### Estilos
TEXT_BOLD=$(tput bold)
TEXT_GREEN=$(tput setaf 2)
TEXT_RESET=$(tput sgr0)
TEXT_ULINE=$(tput sgr 0 1)

### Funciones
usage()
{
	echo "usage: sysinfo [-f file] [-i] [-h]"
}

write_page()
{
	cat << _EOF_
$TEXT_BOLD$TITLE$TEXT_RESET

$(system_info)

$(show_uptime)

$(drive_space)

$(drives_space)

$(home_space)

$(open_files)

$TEXT_GREEN$TIME_STAMP$TEXT_RESET
_EOF_
}

system_info()
{
	echo "${TEXT_ULINE}Versión del sistema${TEXT_RESET}"
	echo
	uname -a
}

show_uptime()
{
	echo "${TEXT_ULINE}Tiempo de encendido del sistema${TEXT_RESET}"
	echo
	uptime | cut -d " " -f 4,5 | tr "," "."
}

drive_space()
{
	echo "${TEXT_ULINE}Espacio en disco o partición disponible${TEXT_RESET}"
  echo
	echo "Disco:  Espacio disponible:"
        df -h | sed "1d" | tr -s " " " " | cut -d " " -f 1,4 | tr " " "\t"
}

home_space()
{
	echo "${TEXT_ULINE}Espacio ocupado por el directorio ${HOME}${TEXT_RESET}"
	echo
	printf "${TEXT_ULINE}%20s %20s %20s %20s${TEXT_RESET}\n" "Directorios" "Archivos" "Usado" "Directorio"
	if [ "$USER_ID" == "0" ]; then
		for dir in $(ls /home); do
			printf "%20s %20s %20s %20s\n" "$(find /home/${dir} -type d | tail -n +2 | wc -l)" "$(find /home/${dir} -type f | wc -l)" "$(du -sh /home/${dir} | cut -d '/' -f 1)" "/home/${dir}  "
		done
  else
		printf "%20s %20s %20s %20s\n" "$(find ~ -type d | tail -n +2 | wc -l)" "$(find ~ -type f | wc -l)" "$(du -sh ~ | cut -d '/' -f 1)" "/home/${USER}  "
  fi

  echo
  echo "${TEXT_ULINE}Número de procesos que se ejecutan hasta ahora${TEXT_RESET}"
  echo
  ps | sed "1d" | wc -l
  echo
  if [ "$USER" != "$LOGNAME" ]; then
    echo "${TEXT_GREEN}El nombre del usuario actual ($USER) no coincide con el nombre del usuario que inició sesión ($LOGNAME).${TEXT_RESET}"
    echo
  fi
}

drives_space()
{
	echo "${TEXT_ULINE}Espacio en disco o partición ocupado${TEXT_RESET}"
        echo
	echo "Disco:  Espacio ocupado:"
        df -h | sed "1,2d" | tr -s " " " " | cut -d " " -f 1,3 | tr " " "\t"
}

open_files()
{
	echo "${TEXT_ULINE}Número de archivos abiertos:${TEXT_RESET}"
	echo
	printf "${TEXT_ULINE}%20s %20s${TEXT_RESET}\n" "Usuario" "Nº Archivos"
	for user in $(cat /etc/passwd | cut -d ":" -f 1 | sort); do
		if [ "$(lsof -u ${user} | wc -l)" != "0" ]; then
			printf "%20s %20s\n" "${user}" "$(lsof -u ${user} | wc -l) "
		fi
	done
}

error_exit()
{
	echo "${PROGNAME}- ${1:-"Error desconocido"}" 1>&2
        exit 1
}

### Programa principal
#### Comprobación de la existencia de comandos.
hash df || error_exit "${LINENO}: Falta un programa básico (df) para el funcionamiento del script."
hash du || error_exit "${LINENO}: Falta un programa básico (du) para el funcionamiento del script."
hash uptime || error_exit "${LINENO}: Falta un programa básico (uptime) para el funcionamiento del script."

#### Procesado de linea de comandos.
while [ "$1" != "" ]; do
	case $1 in
		-f | --file )
			shift
			filename=$1
			;;
		-i | --interactive )
			interactive=1
			;;
		-h | --help )
			usage
			exit 1
			;;
		* )
			usage
			error_exit "Opción no soportada."
			;;
  esac
  shift
done

#### Generar informe y guardar e el archivo indicado.
write_page #> $filename
