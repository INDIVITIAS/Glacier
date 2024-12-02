#!/bin/bash

# Определения цветов и форматирования
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
MAGENTA='\033[0;35m'
RESET='\033[0m'

# Иконки для пунктов меню
ICON_TELEGRAM="🚀"
ICON_INSTALL="🛠️"
ICON_SSH="🔑"
ICON_START="▶️"
ICON_RESTART="🔄"
ICON_LOGS="📄"
ICON_DELETE="🗑️"
ICON_EXIT="❌"

# Функции для рисования границ
draw_top_border() {
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════╗${RESET}"
}

draw_middle_border() {
    echo -e "${CYAN}╠══════════════════════════════════════════════════════════════════════╣${RESET}"
}

draw_bottom_border() {
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════════╝${RESET}"
}

print_telegram_icon() {
    echo -e "          ${MAGENTA}${ICON_TELEGRAM} Подписывайтесь на наш Telegram!${RESET}"
}

# Логотип и информация
display_ascii() {
    echo -e "${CYAN}   ____   _  __   ___    ____ _   __   ____ ______   ____   ___    ____${RESET}"
    echo -e "${CYAN}  /  _/  / |/ /  / _ \\  /  _/| | / /  /  _//_  __/  /  _/  / _ |  / __/${RESET}"
    echo -e "${CYAN} _/ /   /    /  / // / _/ /  | |/ /  _/ /   / /    _/ /   / __ | _\\ \\  ${RESET}"
    echo -e "${CYAN}/___/  /_/|_/  /____/ /___/  |___/  /___/  /_/    /___/  /_/ |_|/___/  ${RESET}"
    echo -e ""
    echo -e "${YELLOW}Подписывайтесь на Telegram: https://t.me/CryptalikBTC${RESET}"
    echo -e "${YELLOW}Подписывайтесь на YouTube: https://www.youtube.com/@Cryptalik${RESET}"
    echo -e "${YELLOW}Здесь про аирдропы и ноды: https://t.me/indivitias${RESET}"
    echo -e "${YELLOW}Купи мне крипто бутылочку... ${ICON_KEFIR}кефира 😏${RESET} ${MAGENTA} 👉  https://bit.ly/4eBbfIr  👈 ${MAGENTA}"
    echo -e ""
    echo -e "${CYAN}Полезные команды:${RESET}"
    echo -e "  - ${YELLOW}Просмотр файлов директории:${RESET} ll"
    echo -e "  - ${YELLOW}Вход в директорию:${RESET} cd hyperlane"
    echo -e "  - ${YELLOW}Выход из директории:${RESET} cd .."
    echo -e "  - ${YELLOW}Запуск меню скрипта (не установка) из директории hyperlane:${RESET} bash hyper.sh"
    echo -e ""
}

# Функция для получения IP-адреса
get_ip_address() {
    ip_address=$(hostname -I | awk '{print $1}')
    if [[ -z "$ip_address" ]]; then
        echo -ne "${YELLOW}Не удалось автоматически определить IP-адрес.${RESET}"
        echo -ne "${YELLOW} Пожалуйста, введите IP-адрес:${RESET} "
        read ip_address
    fi
    echo "$ip_address"
}

# Функция для установки ноды
install_node() {
    echo 'Начинаю установку ноды...'

    sudo apt install lsof

    ports=(10801)

    for port in "${ports[@]}"; do
        if [[ $(lsof -i :"$port" | wc -l) -gt 0 ]]; then
            echo "Ошибка: Порт $port занят. Программа не сможет выполниться."
            exit 1
        fi
    done

    echo -e "Все порты свободны! Сейчас начнется установка...\n"

    sudo apt update -y && sudo apt upgrade -y
    sudo apt-get install nano jq make software-properties-common make gnupg lsb-release ca-certificates curl

    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt update -y && sudo apt install -y docker-ce docker-ce-cli containerd.io
    sudo usermod -aG docker $USER
    sudo apt install -y docker-buildx-plugin docker-compose-plugin

    sudo apt install docker.io -y

    read -p "Введите ваш приватный ключ кошелька: " priv_key
    docker run -d -e PRIVATE_KEY=$priv_key --name glacier-verifier docker.io/glaciernetwork/glacier-verifier:v0.0.2

    if [ $? -eq 0 ]; then
        echo "Контейнер glacier-verifier успешно запущен."
    else
        echo "Ошибка запуска контейнера. Проверьте вводные данные."
    fi
}

# Функция для проверки логов
check_logs() {
    docker logs -f glacier-verifier --tail 300
}

# Функция для перезагрузки ноды
restart_node() {
    echo 'Начинаю перезагрузку...'
    docker restart glacier-verifier
    echo 'Нода была перезагружена.'
}

# Функция для остановки ноды
stop_node() {
    echo 'Начинаю остановку...'
    docker stop glacier-verifier
    echo 'Нода была остановлена.'
}

# Функция для удаления ноды
delete_node() {
    read -p 'Если уверены удалить ноду, введите любую букву (CTRL+C чтобы выйти): ' checkjust
    echo 'Начинаю удалять ноду...'
    docker stop glacier-verifier
    docker kill glacier-verifier
    docker rm glacier-verifier
    echo 'Нода была удалена.'
}

# Функция для выхода из скрипта
exit_from_script() {
    exit 0
}

# Отображение меню
show_menu() {
    clear
    draw_top_border
    display_ascii
    draw_middle_border
    print_telegram_icon
    echo -e "    ${BLUE}Криптан, подпишись!: ${YELLOW}https://t.me/indivitias${RESET}"
    draw_middle_border

    echo -e "    ${YELLOW}Пожалуйста, выберите опцию:${RESET}"
    echo
    echo -e "    ${CYAN}1.${RESET} ${ICON_INSTALL} Установить ноду"
    echo -e "    ${CYAN}2.${RESET} ${ICON_LOGS} Посмотреть логи (выйти CTRL+C)"
    echo -e "    ${CYAN}3.${RESET} ${ICON_RESTART} Перезагрузить ноду"
    echo -e "    ${CYAN}4.${RESET} ${ICON_DELETE} Остановить ноду"
    echo -e "    ${CYAN}5.${RESET} ${ICON_DELETE} Удалить ноду"
    echo -e "    ${CYAN}6.${RESET} ${ICON_EXIT} Выйти из скрипта"
    draw_bottom_border
    echo -e "${CYAN}╔══════════════════════════════════════════════════════╗${RESET}"
    echo -e "${CYAN}║${RESET}              ${YELLOW}Введите свой выбор [1-6]:${RESET}           ${CYAN}║${RESET}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════╝${RESET}"
    read -p " " choice
}

# Основное меню
while true; do
    show_menu
    case $choice in
        1)
            install_node
            ;;
        2)
            check_logs
            ;;
        3)
            restart_node
            ;;
        4)
            stop_node
            ;;
        5)
            delete_node
            ;;
        6)
            exit_from_script
            ;;
        *)
            echo "Неверный пункт. Пожалуйста, выберите правильную цифру в меню."
            ;;
    esac
done
