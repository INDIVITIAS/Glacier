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
    echo -e "${YELLOW}Купи мне крипто бутылочку... кефира 😏${RESET} ${MAGENTA} 👉  https://bit.ly/4eBbfIr  👈 ${MAGENTA}"
    echo -e ""
    echo -e "${CYAN}Полезные команды:${RESET}"
    echo -e "  - ${YELLOW}Просмотр файлов директории:${RESET} ll"
    echo -e "  - ${YELLOW}Вход в директорию:${RESET} cd hyperlane"
    echo -e "  - ${YELLOW}Выход из директории:${RESET} cd .."
    echo -е "  - ${YELLOW}Запуск меню скрипта (не установка) из директории hyperlane:${RESET} bash hyper.sh"
    echo -е ""
}

# Функция для установки ноды
install_node() {
    echo 'Начинаю установку ноды...'

    sudo apt-get update -y
    sudo apt-get install -y lsof curl nano jq make software-properties-common gnupg lsb-release ca-certificates

    ports=(10801)

    for port in "${ports[@]}"; do
        if [[ $(lsof -i :"$port" | wc -l) -gt 0 ]]; then
            echo "Ошибка: Порт $port занят. Программа не сможет выполниться."
            exit 1
        fi
    done

    echo -е "Все порты свободны! Сейчас начнется установка...\n"

    # Установка Docker, если не установлен
    if ! command -v docker &> /dev/null; then
        sudo apt-get install -y docker-ce docker-ce-cli containerd.io
        sudo systemctl start docker
        sudo systemctl enable docker
    fi

    # Перезапуск Docker-демона
    sudo systemctl restart docker

    read -p "Введите ваш приватный ключ кошелька: " priv_key
    echo "PRIVATE_KEY=$priv_key" > .env

    # Создаем уникальную сеть Docker
    docker network create glacier_network

    echo "Запуск docker-compose..."
    docker-compose -f docker-compose.yml -p glacier-verifier up -d --network glacier_network

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
    docker-compose -f docker-compose.yml -p glacier-verifier restart
    echo 'Нода была перезагружена.'
}

# Функция для остановки ноды
stop_node() {
    echo 'Начинаю остановку...'
    docker-compose -f docker-compose.yml -p glacier-verifier stop
    echo 'Нода была остановлена.'
}

# Функция для удаления ноды
delete_node() {
    read -p 'Если уверены удалить ноду, введите любую букву (CTRL+C чтобы выйти): ' checkjust
    echo 'Начинаю удалять ноду...'
    docker-compose -f docker-compose.yml -p glacier-verifier down
    docker network rm glacier_network
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
    echo -е "    ${BLUE}Криптан, подпишись!: ${YELLOW}https://t.me/indivitias${RESET}"
    draw_middle_border

    echo -е "    ${YELLOW}Пожалуйста, выберите опцию:${RESET}"
    echo
    echo -е "    ${CYАН}1.${RESET} ${ICON_INSTALL} Установить ноду"
    echo -е "    ${CYАН}2.${RESET} ${ICON_LOGС} Посмотреть логи (выйти CTRL+C)"
    echo -е "    ${CYАН}3.${RESET} ${ICON_RESTART} Перезагрузить ноду"
    echo -е "    ${CYАН}4.${RESET} ${ICON_DELETE} Остановить ноду"
    echo -е "    ${CYАН}5.${RESET} ${ICON_DELETE} Удалить ноду"
    echo -е "    ${CYАН}6.${RESET} ${ICON_EXIT} Выйти из скрипта"
    draw_bottom_border
    echo -е "${CYАН}╔══════════════════════════════════════════════════════╗${RESET}"
    echo -е "${CYАН}║${RESET}              ${YELLOW}Введите свой выбор [1-6]:${RESET}           ${CYАН}║${RESET}"
    echo -е "${CYАН}╚══════════════════════════════════════════════════════╝${RESET}"
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
