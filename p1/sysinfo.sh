#!/bin/bash
# sysinfo - Un script que informa del estado del sistema.

### Constantes
TITLE="Información del sistema para $HOSTNAME"
RIGHT_NOW=$(date +"%x %r%Z")
TIME_STAMP="Actualizada el $RIGHT_NOW por $USER"
USER_ID=$(id -u)

### Estilos
TEXT_BOLD=$(tput bold)
TEXT_GREEN=$(tput setaf 2)
TEXT_RESET=$(tput sgr0)
TEXT_ULINE=$(tput sgr 0 1)

### Opciones por defecto.
interactive=
filename=~/sysinfo.txt

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
	if [ "$USER_ID" == "0" ]; then
          du -s /home/* | sort -nr
        else
          du -sh ~
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

error_exit()
{
	echo "${PROGNAME}: ${1:-"Error desconocido"}" 1>&2
        exit 1
}

### Programa principal
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
		* )
			usage
			exit 1
  esac
  shift
done

#### Generar informe y guardar e el archivo indicado.
write_page > $filename
