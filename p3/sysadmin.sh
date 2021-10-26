# sysadmin - Un script que facilita la administración del sistema, consultando el consumo de los procesos de los usuarios.

### Constantes
TITLE="User and process information."
RIGHT_NOW=$(date +"%x %r%Z")
TIME_STAMP="Updated at $RIGHT_NOW by $USER"
PROGNAME="sysadmin.sh"
REALUSERMINUID=$(awk '/^UID_MIN/ {print $2}' /etc/login.defs)
REALUSERMAXUID=$(awk '/^UID_MAX/ {print $2}' /etc/login.defs)

### Opciones por defecto.
online=0
offline=0
uidsort=0
reversesort=0
kill=0
killparam=0

### Estilos
TEXT_BOLD=$(tput bold)
TEXT_GREEN=$(tput setaf 2)
TEXT_RESET=$(tput sgr0)
TEXT_ULINE=$(tput sgr 0 1)

### Funciones
usage()
{
	echo
	echo "Usage:"
	echo " ./sysadmin [options]"
	echo "Options:"
	echo " [-ON]  or [--online]      Display only real users."
	echo " [-OFF] or [--offline]     Display only non-real users."
	echo " [-U]   or [--uid]         Show data sorted by UID number."
	echo " [-R]   or [--reverse]     Show data with reverse sorting method."
	echo " [-k N] or [--kill N]      Delete all processes with more than N files opened."
	echo " [-h]   or [--help]        Displays usage info."
	echo
}

error_exit()
{
	echo "${PROGNAME}- ${1:-"Error desconocido"}" 1>&2
	echo
	exit 1
}

getmax_cputime_process()
{
	cpu_n="$(ps -U ${1} -u ${1} -o time,comm --sort=time | sed "1d" | tail -n 1 | awk '{ print $2 }')"
	cpu_t="$(ps -U ${1} -u ${1} -o time --sort=time | sed "1d" | tail -n 1)"
}

getmax_exetime_process()
{
	exe_n="$(ps -u ${1} -U ${1} -o etime,comm --sort=etime | tail -n 1 | awk '{ print $2 }')"
	exe_t="$(ps -u ${1} -U ${1} -o etime,comm --sort=etime | tail -n 1 | awk '{ print $1 }')"
}

process_user()
{
	getmax_cputime_process "${1}"
	getmax_exetime_process "${1}"
	printf "%20s %5i %5i %20s %10s %20s %10s %12i %15i\n" "${1}" "$(id -u ${1})" "$(id -g ${1})" "${cpu_n}" "${cpu_t}" "${exe_n}" "${exe_t}" "$(lsof -u ${1} 2> /dev/null | sed "1d" | wc -l)" "$(ps -u ${1} -U ${1} | sed "1d" | wc -l)"
}

show_header()
{
	echo
	echo "${TEXT_BOLD}${TITLE}${TEXT_RESET}"
	printf "%65s  %30s\n" "| Most cpu consuming process |" "|  Oldest process  |"
	printf "${TEXT_ULINE}%20s %5s %5s %20s %10s %20s %10s %12s %15s${TEXT_RESET}\n" "User" "UID" "GID" "Name" "CPUtime" "Name" "Lifetime" "Open Files" "Process owned"
}

check_flags()
{
	if [ "${online}" == "${offline}" ]; then
		online=1
		offline=1
	fi
}

### Programa principal
#### Comprobación de la existencia de comandos.
hash df || error_exit "${LINENO}: Command [df] is required and not installed."
hash du || error_exit "${LINENO}: Command [du] is required and not installed."
hash uptime || error_exit "${LINENO}: Command [uptime] is required and not installed."
hash id || error_exit "${LINENO}: Command [id] is required and not installed."
hash ps || error_exit "${LINENO}: Command [ps] is required and not installed."
hash lsof || error_exit "${LINENO}: Command [lsof] is required and not installed."
hash kill || error_exit "${LINENO}: Command [kill] is required and not installed."

#### Procesado de linea de comandos.
while [ "$1" != "" ]; do
	case $1 in
		-ON | --online )
			online=1
			;;
		-OFF | --offline )
			offline=1
			;;
		-U | --uid )
			uidsort=1
			;;
		-R | --reverse )
			reversesort=1
			;;
		-k | --kill )
			kill=1
			shift
			if [[ $1 == *[0-9]* ]]; then
				killparam=$1
			else
				error_exit "Bad use of [-k N] or [--kill N], N is not a digit."
			fi
			;;
		-h | --help )
			usage
			exit 1
			;;
		* )
			usage
			error_exit "Unknown option: [${1}]."
			;;
  esac
  shift
done

#### Elección de criterio de ordenación.
if [ "${uidsort}" -eq "0" ] && [ "${reversesort}" -eq "0" ]; then
	userlist=$(ps -A -o user --sort=user | sed "1d" | uniq)
elif [ "${uidsort}" -eq "1" ] && [ "${reversesort}" -eq "0" ]; then
	userlist=$(ps -A -o user --sort=uid | sed "1d" | uniq)
elif [ "${uidsort}" -eq "0" ] && [ "${reversesort}" -eq "1" ]; then
	userlist=$(ps -A -o user --sort=-user | sed "1d" | uniq)
elif [ "${uidsort}" -eq "1" ] && [ "${reversesort}" -eq "1" ]; then
	userlist=$(ps -A -o user --sort=-uid | sed "1d" | uniq)
else
	error_exit "This error should never pop up."
fi

#### Despliegue de información.
check_flags
show_header
for u in ${userlist}; do
	if [ "${online}" -eq "1" ]; then
		if [ "$(id -u ${u})" -ge "${REALUSERMINUID}" ] && [ "$(id -u ${u})" -le "${REALUSERMAXUID}" ]; then
			process_user "${u}" || error_exit "User ${u} couldn't be processed."
		fi
	fi
	if [ "${offline}" -eq "1" ]; then
		if [ "$(id -u ${u})" -lt "${REALUSERMINUID}" ] || [ "$(id -u ${u})" -gt "${REALUSERMAXUID}" ]; then
			process_user "${u}" || error_exit "User ${u} couldn't be processed."
		fi
	fi
done
printf "%136s\n" "${TEXT_GREEN}${TIME_STAMP}${TEXT_RESET}"

#### Flag kill files.
if [ "${kill}" -eq "1" ]; then
	for pid in $(ps -A -o pid --sort=pid --no-headers); do
		if [ "$(lsof -p ${pid} 2> /dev/null | sed "1d" | wc -l)" -gt "${killparam}" ]; then
			kill ${pid} 2> /dev/null || echo "Process with PID ${pid} won't die."
		fi
	done
fi
