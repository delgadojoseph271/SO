#!/bin/bash
# berribear - CLI Diagnostics & Admin

VERDE='\033[0;32m'; ROJO='\033[0;31m'; AMARILLO='\033[1;33m'
ROSA='\033[1;35m'; CIAN='\033[0;36m'; RESET='\033[0m'

# ---------- Barra de progreso ----------
barra() {
    local pct=$1 ancho=20 lleno vacio
    lleno=$(( pct * ancho / 100 ))
    vacio=$(( ancho - lleno ))
    printf "["
    printf "%${lleno}s" "" | tr ' ' '█'
    printf "%${vacio}s" "" | tr ' ' '░'
    printf "] %s%%" "$pct"
}

# ---------- Banner ----------
banner() {
    clear
    echo -e "${ROSA}"
    if command -v figlet &>/dev/null; then
        figlet -f big "BERRI BEAR"
    else
        echo "=== BERRI BEAR ==="
    fi
    echo -e "${RESET}"
    echo -e "  CLI DIAGNOSTICS & ADMIN - v1.0.0"
    echo -e "  La garra que tu Raspberry Pi necesita\n"
}

# ---------- Panel de estado ----------
estado() {
    # Temperatura
    local temp pct_t
    temp=$(vcgencmd measure_temp 2>/dev/null | grep -oP '[0-9.]+' | head -1)
    temp=${temp:-0}
    pct_t=${temp%.*}
    echo -ne "${VERDE}[✔]${RESET} CPU Temp: ${temp}°C   "
    barra "$pct_t"; echo

    # RAM
    local usada total pct_r
    read -r total usada < <(free -m | awk '/Mem:/ {print $2, $3}')
    pct_r=$(( usada * 100 / total ))
    echo -ne "${VERDE}[✔]${RESET} RAM:      ${usada}MB/${total}MB   "
    barra "$pct_r"; echo

    # Almacenamiento
    local du dt pct_d
    read -r du dt pct_d < <(df -h / | awk 'NR==2 {print $3, $2, $5}')
    echo -ne "${VERDE}[✔]${RESET} Storage:  ${du}/${dt}   "
    barra "${pct_d%\%}"; echo

    # Carga CPU
    echo -e "${VERDE}[✔]${RESET} CPU Load: $(awk '{print $1", "$2", "$3}' /proc/loadavg)"

    # Red
    local iface ip
    iface=$(ip route | awk '/default/ {print $5; exit}')
    ip=$(ip -4 addr show "$iface" 2>/dev/null | awk '/inet / {print $2}' | cut -d/ -f1)
    if [ -n "$ip" ]; then
        echo -e "${VERDE}[✔]${RESET} Network:  Connected [$iface] (IP: $ip)"
    else
        echo -e "${ROJO}[✘]${RESET} Network:  Sin conexión"
    fi

    # Uptime
    echo -e "${VERDE}[✔]${RESET} System:   $(uptime -p)"
    echo
}

# ---------- Menú ----------
menu() {
    echo -e "${CIAN}  1)${RESET} Info del sistema      ${CIAN} 6)${RESET} Ver rutas"
    echo -e "${CIAN}  2)${RESET} Uso de CPU/RAM        ${CIAN} 7)${RESET} Ping a internet"
    echo -e "${CIAN}  3)${RESET} Espacio en disco      ${CIAN} 8)${RESET} Escanear red local"
    echo -e "${CIAN}  4)${RESET} Temperatura           ${CIAN} 9)${RESET} Cambiar hostname"
    echo -e "${CIAN}  5)${RESET} Interfaces de red     ${CIAN}10)${RESET} Reiniciar"
    echo -e "${CIAN}  0)${RESET} Salir\n"
}

pausa() { echo; read -rp "Presiona ENTER para continuar..."; }

# ---------- Funciones de las opciones (pon tus comandos aquí) ----------
opcion1()  { uname -a; }
opcion2()  { top -bn1 | head -5; }
opcion3()  { df -h; }
opcion4()  { vcgencmd measure_temp; }
opcion5()  { ip -br addr; }
opcion6()  { ip route; }
opcion7()  { ping -c 4 8.8.8.8; }
opcion8()  { echo "Aquí tu comando de escaneo"; }
opcion9()  { read -rp "Nuevo hostname: " h; sudo hostnamectl set-hostname "$h"; }
opcion10() { read -rp "¿Seguro? (s/n): " r; [[ $r == s ]] && sudo reboot; }

# ---------- Bucle principal ----------
while true; do
    banner
    estado
    menu
    read -rp "$(echo -e "${ROSA}berribear > ${RESET}")" op
    echo
    case $op in
        1) opcion1 ;;  2) opcion2 ;;  3) opcion3 ;;  4) opcion4 ;;
        5) opcion5 ;;  6) opcion6 ;;  7) opcion7 ;;  8) opcion8 ;;
        9) opcion9 ;;  10) opcion10 ;;
        0) echo "¡Hasta pronto! 🐻"; exit 0 ;;
        *) echo -e "${ROJO}Opción inválida${RESET}" ;;
    esac
    pausa
done