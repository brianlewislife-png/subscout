#!/bin/bash

# ============================================================
#   SUBSCOUT - Subdomain Scanner
#   Developer: Brian Lewis
#   Instagram: @Brian_lewis_2
#   Platform: Termux (Android) / Linux
# ============================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORDLIST="$SCRIPT_DIR/wordlist.txt"
RESULTS_DIR="$SCRIPT_DIR/results"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# ============================================================
#   COLORS
# ============================================================

C='\033[0;36m'    # Cyan
P='\033[0;35m'    # Purple
B='\033[0;34m'    # Blue
G='\033[0;32m'    # Green
Y='\033[1;33m'    # Yellow
R='\033[0;31m'    # Red
W='\033[1;37m'    # White
D='\033[2;37m'    # Dark
NC='\033[0m'      # Reset
BOLD='\033[1m'    # Bold

# ============================================================
#   BANNER
# ============================================================

show_banner() {
    printf "\033c"
    echo ""
    echo -e "${C}"
    cat << 'BANNER'

   ____        _       ____  _______
  / ___|  ___(_)_ __ / ___||  ___|__  _ __ ___ ___
  \___ \ / _ \ | '__| |    | |_ / _ \| '__/ __/ _ \
   ___) |  __/ | |  | |___ |  _| (_) | | | (_|  __/
  |____/ \___|_|_|   \____||_|  \___/|_|  \___\___|

BANNER
    echo -e "${NC}"
    echo -e "  ${P}╔═══════════════════════════════════════════════╗${NC}"
    echo -e "  ${P}║${NC}       ${W}S U B D O M A I N   S C A N N E R${NC}       ${P}║${NC}"
    echo -e "  ${P}╚═══════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "  ${D}Desenvolvido por: ${W}Brian Lewis${NC}"
    echo -e "  ${D}Instagram: ${P}@Brian_lewis_2${NC}"
    echo ""
}

# ============================================================
#   CHECK DEPENDENCIES
# ============================================================

check_deps() {
    echo -e "${Y}[*]${NC} Verificando dependencias..."
    echo ""

    local missing=0
    for cmd in host dig nslookup curl; do
        if command -v "$cmd" > /dev/null 2>&1; then
            echo -e "  ${G}[OK]${NC} $cmd"
        else
            echo -e "  ${D}[--]${NC} $cmd (nao encontrado)"
            missing=$((missing + 1))
        fi
    done

    if [ "$missing" -eq 3 ]; then
        echo ""
        echo -e "  ${R}[!]${NC} Nenhuma ferramenta DNS encontrada."
        echo -e "  ${D}Instale: pkg install dnsutils curl${NC}"
        return 1
    fi
    echo ""
    return 0
}

# ============================================================
#   DNS RESOLUTION METHOD
# ============================================================

resolve_subdomain() {
    local subdomain="$1"
    local target="$2"

    # Try host command first
    if command -v host > /dev/null 2>&1; then
        local result=$(host "$subdomain.$target" 2>/dev/null | head -1)
        if echo "$result" | grep -qi "has address\|has IPv6\|domain name\|mail exchanger"; then
            local ip=$(echo "$result" | grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -1)
            echo "${ip:-found}"
            return 0
        fi
    fi

    # Try dig command
    if command -v dig > /dev/null 2>&1; then
        local result=$(dig +short "$subdomain.$target" 2>/dev/null | head -1)
        if [ -n "$result" ] && [ "$result" != "" ]; then
            echo "$result"
            return 0
        fi
    fi

    # Try nslookup
    if command -v nslookup > /dev/null 2>&1; then
        local result=$(nslookup "$subdomain.$target" 2>/dev/null | grep -i "address:" | tail -1 | awk '{print $2}')
        if [ -n "$result" ] && [ "$result" != "127.0.0.53" ] && [ "$result" != "127.0.0.1" ]; then
            echo "$result"
            return 0
        fi
    fi

    # Fallback: curl check
    if command -v curl > /dev/null 2>&1; then
        local result=$(curl -s --max-time 3 --connect-timeout 2 -o /dev/null -w "%{http_code}" "http://$subdomain.$target" 2>/dev/null)
        if [ "$result" != "000" ] && [ -n "$result" ]; then
            echo "http:$result"
            return 0
        fi
    fi

    return 1
}

# ============================================================
#   SCANNER
# ============================================================

scan_subdomains() {
    local target="$1"
    local threads="$2"
    local output_file="$3"

    echo -e "${C}╔═══════════════════════════════════════════════╗${NC}"
    echo -e "${C}║${NC}          ${W}S C A N N I N G${NC}                       ${C}║${NC}"
    echo -e "${C}╚═══════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "  ${D}Alvo:${NC}        ${W}$target${NC}"
    echo -e "  ${D}Wordlist:${NC}    ${W}$(wc -l < "$WORDLIST")${NC} ${D}entradas${NC}"
    echo -e "  ${D}Threads:${NC}     ${W}$threads${NC}"
    echo -e "  ${D}Resultado:${NC}   ${W}$output_file${NC}"
    echo ""
    echo -e "  ${Y}Iniciando varredura...${NC}"
    echo ""
    echo -e "${C}───────────────────────────────────────────────${NC}"

    mkdir -p "$RESULTS_DIR"

    local total=$(wc -l < "$WORDLIST")
    local count=0
    local found=0
    local start_time=$(date +%s)

    while IFS= read -r subdomain; do
        # Skip empty lines and comments
        [[ -z "$subdomain" || "$subdomain" =~ ^# ]] && continue

        count=$((count + 1))
        local progress=$((count * 100 / total))

        # Show progress
        printf "\r  ${D}[${NC}${W}%3d%%${NC}${D}]${NC} ${D}Testando:${NC} ${W}%-30s${NC}" "$progress" "$subdomain.$target"

        # Resolve
        local ip=$(resolve_subdomain "$subdomain" "$target" 2>/dev/null)

        if [ $? -eq 0 ] && [ -n "$ip" ]; then
            found=$((found + 1))
            echo ""
            echo -e "  ${G}[+]${NC} ${W}$subdomain.$target${NC} ${D}→${NC} ${C}$ip${NC}"

            # Save to file
            echo "$subdomain.$target | $ip" >> "$output_file"
        fi

        # Rate limiting
        [ "$threads" -le 1 ] && sleep 0.1
        [ "$threads" -le 5 ] && sleep 0.05

    done < "$WORDLIST"

    local end_time=$(date +%s)
    local duration=$((end_time - start_time))

    echo ""
    echo ""
    echo -e "${C}───────────────────────────────────────────────${NC}"
    echo ""
    echo -e "  ${G}[OK]${NC} Varredura completa!"
    echo ""
    echo -e "  ${D}Tempo:${NC}       ${W}${duration}s${NC}"
    echo -e "  ${D}Testados:${NC}    ${W}$count${NC}"
    echo -e "  ${D}Encontrados:${NC} ${G}$found${NC}"
    echo -e "  ${D}Salvo em:${NC}    ${W}$output_file${NC}"
    echo ""
}

# ============================================================
#   SHOW RESULTS
# ============================================================

show_results() {
    local file="$1"

    if [ ! -f "$file" ] || [ ! -s "$file" ]; then
        echo -e "  ${D}Nenhum subdominio encontrado.${NC}"
        return
    fi

    echo -e "${C}╔═══════════════════════════════════════════════╗${NC}"
    echo -e "${C}║${NC}         ${W}R E S U L T A D O S${NC}                    ${C}║${NC}"
    echo -e "${C}╚═══════════════════════════════════════════════╝${NC}"
    echo ""
    cat "$file" | column -t -s '|' 2>/dev/null || cat "$file"
    echo ""
}

# ============================================================
#   MENU
# ============================================================

show_menu() {
    echo -e "  ${P}╔═══════════════════════════════════════════════╗${NC}"
    echo -e "  ${P}║${NC}              ${W}M E N U${NC}                          ${P}║${NC}"
    echo -e "  ${P}╠═══════════════════════════════════════════════╣${NC}"
    echo -e "  ${P}║${NC}                                               ${P}║${NC}"
    echo -e "  ${P}║${NC}  ${C}[1]${NC}  ${W}Scan rapido${NC}         ${D}(500 entradas)${NC}    ${P}║${NC}"
    echo -e "  ${P}║${NC}  ${C}[2]${NC}  ${W}Scan medio${NC}          ${D}(1500 entradas)${NC}   ${P}║${NC}"
    echo -e "  ${P}║${NC}  ${C}[3]${NC}  ${W}Scan completo${NC}       ${D}(3500+ entradas)${NC}  ${P}║${NC}"
    echo -e "  ${P}║${NC}  ${C}[4]${NC}  ${W}Scan customizado${NC}    ${D}(sua wordlist)${NC}    ${P}║${NC}"
    echo -e "  ${P}║${NC}                                               ${P}║${NC}"
    echo -e "  ${P}║${NC}  ${C}[5]${NC}  ${W}Ver resultados anteriores${NC}                ${P}║${NC}"
    echo -e "  ${P}║${NC}  ${C}[6]${NC}  ${W}Sobre${NC}                                  ${P}║${NC}"
    echo -e "  ${P}║${NC}                                               ${P}║${NC}"
    echo -e "  ${P}║${NC}  ${R}[0]${NC}  ${D}Sair${NC}                                     ${P}║${NC}"
    echo -e "  ${P}║${NC}                                               ${P}║${NC}"
    echo -e "  ${P}╚═══════════════════════════════════════════════╝${NC}"
    echo ""
    echo -ne "  ${C}>${NC} ${W}Selecione: ${NC}"
}

# ============================================================
#   SCAN PRESETS
# ============================================================

preset_scan() {
    local target="$1"
    local mode="$2"

    local scan_list="$SCRIPT_DIR/scan_list_$$.txt"
    local output_file="$RESULTS_DIR/${target}_${TIMESTAMP}.txt"

    case "$mode" in
        1)
            # Quick: top 500
            head -500 "$WORDLIST" | grep -v '^#' | grep -v '^$' > "$scan_list"
            local threads=1
            ;;
        2)
            # Medium: top 1500
            head -1500 "$WORDLIST" | grep -v '^#' | grep -v '^$' > "$scan_list"
            local threads=5
            ;;
        3)
            # Full: everything
            grep -v '^#' "$WORDLIST" | grep -v '^$' > "$scan_list"
            local threads=10
            ;;
    esac

    # Replace wordlist temporarily
    local orig_wordlist="$WORDLIST"
    WORDLIST="$scan_list"

    scan_subdomains "$target" "$threads" "$output_file"

    WORDLIST="$orig_wordlist"
    rm -f "$scan_list"

    show_results "$output_file"
}

# ============================================================
#   CUSTOM SCAN
# ============================================================

custom_scan() {
    echo ""
    echo -ne "  ${C}>${NC} ${W}Caminho da wordlist: ${NC}"
    read -r custom_wl

    if [ ! -f "$custom_wl" ]; then
        echo -e "  ${R}[!]${NC} Arquivo nao encontrado."
        return
    fi

    echo -ne "  ${C}>${NC} ${W}Threads (1-20): ${NC}"
    read -r threads
    [ -z "$threads" ] && threads=5
    [ "$threads" -gt 20 ] && threads=20

    local output_file="$RESULTS_DIR/${target}_${TIMESTAMP}_custom.txt"

    local orig_wordlist="$WORDLIST"
    WORDLIST="$custom_wl"

    scan_subdomains "$target" "$threads" "$output_file"

    WORDLIST="$orig_wordlist"

    show_results "$output_file"
}

# ============================================================
#   VIEW RESULTS
# ============================================================

view_results() {
    printf "\033c"
    echo ""
    echo -e "${C}╔═══════════════════════════════════════════════╗${NC}"
    echo -e "${C}║${NC}       ${W}R E S U L T A D O S${NC}                       ${C}║${NC}"
    echo -e "${C}╚═══════════════════════════════════════════════╝${NC}"
    echo ""

    mkdir -p "$RESULTS_DIR"

    local files=()
    for f in "$RESULTS_DIR"/*.txt; do
        [ -f "$f" ] && files+=("$f")
    done

    if [ ${#files[@]} -eq 0 ]; then
        echo -e "  ${D}Nenhum resultado encontrado.${NC}"
        echo -ne "  ${D}Pressione ENTER para voltar...${NC}"
        read -r
        return
    fi

    echo -e "  ${W}Arquivos encontrados:${NC}"
    echo ""
    local i=1
    for f in "${files[@]}"; do
        local name=$(basename "$f")
        local count=$(wc -l < "$f")
        echo -e "  ${C}[$i]${NC} ${W}$name${NC} ${D}($count subdominios)${NC}"
        ((i++))
    done
    echo -e "  ${D}[0]${NC}  Voltar"
    echo ""
    echo -ne "  ${C}>${NC} ${W}Selecione: ${NC}"
    read -r choice

    if [ "$choice" -ge 1 ] && [ "$choice" -le ${#files[@]} ]; then
        local selected="${files[$((choice-1))]}"
        echo ""
        show_results "$selected"
    fi

    echo -ne "  ${D}Pressione ENTER para voltar...${NC}"
    read -r
}

# ============================================================
#   ABOUT
# ============================================================

show_about() {
    printf "\033c"
    echo ""
    echo -e "${C}"
    cat << 'ABOUT'

   ____        _       ____  _______
  / ___|  ___(_)_ __ / ___||  ___|__  _ __ ___ ___
  \___ \ / _ \ | '__| |    | |_ / _ \| '__/ __/ _ \
   ___) |  __/ | |  | |___ |  _| (_) | | | (_|  __/
  |____/ \___|_|_|   \____||_|  \___/|_|  \___\___|

ABOUT
    echo -e "${NC}"
    echo -e "  ${P}╔═══════════════════════════════════════════════╗${NC}"
    echo -e "  ${P}║${NC}       ${W}S U B D O M A I N   S C A N N E R${NC}       ${P}║${NC}"
    echo -e "  ${P}╚═══════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "  ${W}Ferramenta criada e desenvolvida por:${NC}"
    echo ""
    echo -e "  ${C}  ██████╗ ██╗${NC}   ${C}██╗${NC}"
    echo -e "  ${C}  ██╔══██╗██║${NC}   ${C}██║${NC}"
    echo -e "  ${C}  ██████╔╝██║${NC}   ${C}██║${NC}     ${W}Brian Lewis${NC}"
    echo -e "  ${C}  ██╔══██╗██║${NC}   ${C}██║${NC}"
    echo -e "  ${C}  ██████╔╝╚██████╔╝${NC}     ${P}@Brian_lewis_2${NC}"
    echo -e "  ${C}  ╚═════╝  ╚═════╝${NC}"
    echo ""
    echo -e "  ${D}Instagram: ${P}@Brian_lewis_2${NC}"
    echo ""
    echo -e "  ${W}Scanner de subdominios para Termux/Linux.${NC}"
    echo -e "  ${W}Usa wordlist com 3500+ entradas para encontrar${NC}"
    echo -e "  ${W}subdominios de qualquer dominio.${NC}"
    echo ""
    echo -e "  ${C}Version:  ${W}1.0.0${NC}"
    echo -e "  ${C}License:  ${W}MIT${NC}"
    echo -e "  ${C}Platform:${W} Termux (Android) / Linux${NC}"
    echo ""
    echo -e "  ${D}GitHub: https://github.com/brianlewislife-png/SubScout${NC}"
    echo ""
    echo -ne "  ${D}Pressione ENTER para voltar...${NC}"
    read -r
}

# ============================================================
#   MAIN
# ============================================================

main() {
    mkdir -p "$RESULTS_DIR"

    show_banner
    check_deps || exit 1

    while true; do
        show_menu
        read -r option
        echo ""

        case "$option" in
            1|2|3)
                echo -ne "  ${C}>${NC} ${W}Dominio alvo (ex: example.com): ${NC}"
                read -r target
                target=$(echo "$target" | sed 's|https*://||;s|/.*||' | tr '[:upper:]' '[:lower:]')

                if [ -z "$target" ]; then
                    echo -e "  ${R}[!]${NC} Dominio invalido."
                    sleep 1
                    continue
                fi

                preset_scan "$target" "$option"
                echo -ne "  ${D}Pressione ENTER para voltar...${NC}"
                read -r
                ;;
            4)
                echo -ne "  ${C}>${NC} ${W}Dominio alvo (ex: example.com): ${NC}"
                read -r target
                target=$(echo "$target" | sed 's|https*://||;s|/.*||' | tr '[:upper:]' '[:lower:]')

                if [ -z "$target" ]; then
                    echo -e "  ${R}[!]${NC} Dominio invalido."
                    sleep 1
                    continue
                fi

                custom_scan
                echo -ne "  ${D}Pressione ENTER para voltar...${NC}"
                read -r
                ;;
            5)
                view_results
                ;;
            6)
                show_about
                ;;
            0)
                printf "\033c"
                echo ""
                echo -e "${C}========================================${NC}"
                echo -e "${W}  Obrigado por usar o${NC}"
                echo -e "${W}  ${P}SUBSCOUT${NC}"
                echo -e "${C}========================================${NC}"
                echo ""
                echo -e "${D}Desenvolvido por:${NC}"
                echo -e "${W}Brian Lewis${NC}"
                echo -e "${P}@Brian_lewis_2${NC}"
                echo ""
                echo -e "${C}========================================${NC}"
                echo ""
                exit 0
                ;;
            *)
                echo -e "  ${R}[!]${NC} Opcao invalida."
                sleep 1
                ;;
        esac
    done
}

main
