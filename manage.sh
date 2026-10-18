#!/usr/bin/env bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Helper for docker compose command
get_docker_compose() {
    if command -v docker &>/dev/null && docker compose version &>/dev/null; then
        echo "docker compose"
    elif command -v docker-compose &>/dev/null; then
        echo "docker-compose"
    else
        echo ""
    fi
}

ensure_output_file() {
    if [ ! -f "output.txt" ]; then
        touch output.txt
    fi
}

ensure_env_file() {
    if [ ! -f ".env" ]; then
        if [ -f ".env.example" ]; then
            cp .env.example .env
            echo -e "${GREEN}✓ File .env berhasil dibuat dari .env.example!${NC}"
        else
            echo "THREADS_COUNT=1" > .env
            echo "DELAY=25" >> .env
            echo "OUTPUT_FILE=output.txt" >> .env
            echo "OUTPUT_FORMAT={key} | {referral_count}" >> .env
            echo -e "${GREEN}✓ File .env default berhasil dibuat!${NC}"
        fi
    fi
}

install_dependencies() {
    echo -e "${BLUE}=== Install Docker & Docker Compose ===${NC}"
    if command -v docker &>/dev/null; then
        echo -e "${GREEN}✓ Docker sudah terinstall.${NC}"
        return 0
    fi

    echo -e "${YELLOW}Menginstall Docker...${NC}"
    if [ -f /etc/debian_version ]; then
        sudo apt-get update -y
        sudo apt-get install -y curl git
        curl -fsSL https://get.docker.com | sh
        sudo usermod -aG docker "$USER" 2>/dev/null || true
    elif [ -f /etc/redhat-release ]; then
        sudo yum check-update -y || true
        sudo yum install -y curl git
        curl -fsSL https://get.docker.com | sh
        sudo systemctl start docker
        sudo systemctl enable docker
    else
        echo -e "${RED}Sistem operasi tidak dikenali secara otomatis. Silakan install Docker secara manual.${NC}"
        return 1
    fi

    echo -e "${GREEN}✓ Docker berhasil diinstall!${NC}"
}

start_app() {
    ensure_env_file
    ensure_output_file

    DOCKER_COMPOSE=$(get_docker_compose)
    if [ -z "$DOCKER_COMPOSE" ]; then
        echo -e "${RED}Docker Compose belum terinstall! Jalankan opsi install terlebih dahulu.${NC}"
        return 1
    fi

    echo -e "${BLUE}Memulai Warp Cloner...${NC}"
    $DOCKER_COMPOSE up -d --build
    echo -e "${GREEN}✓ Warp Cloner berhasil dijalankan di background!${NC}"
}

stop_app() {
    DOCKER_COMPOSE=$(get_docker_compose)
    if [ -n "$DOCKER_COMPOSE" ]; then
        echo -e "${YELLOW}Menghentikan Warp Cloner...${NC}"
        $DOCKER_COMPOSE down
        echo -e "${GREEN}✓ Warp Cloner telah dihentikan.${NC}"
    else
        echo -e "${RED}Docker Compose tidak ditemukan.${NC}"
    fi
}

restart_app() {
    echo -e "${YELLOW}Merestart Warp Cloner...${NC}"
    stop_app
    start_app
}

show_status() {
    DOCKER_COMPOSE=$(get_docker_compose)
    if [ -n "$DOCKER_COMPOSE" ]; then
        echo -e "${BLUE}=== Status Warp Cloner ===${NC}"
        $DOCKER_COMPOSE ps
    else
        echo -e "${RED}Docker Compose tidak ditemukan.${NC}"
    fi
}

show_logs() {
    DOCKER_COMPOSE=$(get_docker_compose)
    if [ -n "$DOCKER_COMPOSE" ]; then
        echo -e "${BLUE}=== Log Warp Cloner (Ctrl+C untuk keluar) ===${NC}"
        $DOCKER_COMPOSE logs -f
    else
        echo -e "${RED}Docker Compose tidak ditemukan.${NC}"
    fi
}

view_keys() {
    ensure_output_file
    TOTAL=$(grep -c . output.txt 2>/dev/null || echo 0)
    echo -e "${BLUE}=== Generated Keys (Total: $TOTAL) ===${NC}"
    if [ -s output.txt ]; then
        tail -n 30 output.txt
    else
        echo -e "${YELLOW}Belum ada key yang dihasilkan.${NC}"
    fi
}

update_app() {
    echo -e "${BLUE}Mengupdate Warp Cloner ke versi terbaru...${NC}"
    git pull
    restart_app
}

show_menu() {
    while true; do
        echo -e "\n${CYAN}==========================================${NC}"
        echo -e "${CYAN}    ⚡ WARP CLONER - VPS MANAGER ⚡      ${NC}"
        echo -e "${CYAN}==========================================${NC}"
        echo -e "${GREEN}1.${NC} Start / Jalankan Warp Cloner"
        echo -e "${GREEN}2.${NC} Stop / Hentikan Warp Cloner"
        echo -e "${GREEN}3.${NC} Restart Warp Cloner"
        echo -e "${GREEN}4.${NC} Lihat Status Container"
        echo -e "${GREEN}5.${NC} Lihat Log / Monitoring Real-time"
        echo -e "${GREEN}6.${NC} Lihat Hasil Key (output.txt)"
        echo -e "${GREEN}7.${NC} Edit Konfigurasi (.env)"
        echo -e "${GREEN}8.${NC} Update Aplikasi (Git Pull & Rebuild)"
        echo -e "${GREEN}9.${NC} Install Docker & Dependencies"
        echo -e "${RED}0.${NC} Keluar"
        echo -e "${CYAN}------------------------------------------${NC}"
        read -rp "Pilih menu [0-9]: " choice

        case $choice in
            1) start_app ;;
            2) stop_app ;;
            3) restart_app ;;
            4) show_status ;;
            5) show_logs ;;
            6) view_keys ;;
            7)
                ensure_env_file
                if command -v nano &>/dev/null; then
                    nano .env
                else
                    vi .env
                fi
                ;;
            8) update_app ;;
            9) install_dependencies ;;
            0) echo "Terima kasih!"; exit 0 ;;
            *) echo -e "${RED}Pilihan tidak valid!${NC}" ;;
        esac
    done
}

# Command argument handler
case "$1" in
    start) start_app ;;
    stop) stop_app ;;
    restart) restart_app ;;
    status) show_status ;;
    logs) show_logs ;;
    keys) view_keys ;;
    install) install_dependencies ;;
    update) update_app ;;
    "") show_menu ;;
    *)
        echo "Penggunaan: $0 {start|stop|restart|status|logs|keys|install|update}"
        exit 1
        ;;
esac
