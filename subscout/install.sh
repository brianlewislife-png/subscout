#!/bin/bash

# ============================================================
#   SUBSCOUT - Installer
#   Developer: Brian Lewis
#   Instagram: @Brian_lewis_2
# ============================================================

INSTALL_DIR="$HOME/.subscout"
REPO_URL="https://github.com/brianlewislife-png/SubScout.git"

CYAN='\033[0;36m'
PURPLE='\033[0;35m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
WHITE='\033[1;37m'
DARK='\033[2;37m'
NC='\033[0m'

printf "\033c"

echo -e "${CYAN}"
cat << 'HEADER'

   ____        _       ____  _______
  / ___|  ___(_)_ __ / ___||  ___|__  _ __ ___ ___
  \___ \ / _ \ | '__| |    | |_ / _ \| '__/ __/ _ \
   ___) |  __/ | |  | |___ |  _| (_) | | | (_|  __/
  |____/ \___|_|_|   \____||_|  \___/|_|  \___\___|

HEADER
echo -e "${NC}"
echo -e "  ${DARK}Desenvolvido por: ${WHITE}Brian Lewis${NC}"
echo -e "  ${DARK}Instagram: ${PURPLE}@Brian_lewis_2${NC}"
echo ""

# ============================================================
#   CHECK TERMUX
# ============================================================

IS_TERMUX=0
if [ -d "/data/data/com.termux" ]; then
    IS_TERMUX=1
fi

# ============================================================
#   IF ALREADY INSTALLED, JUST LAUNCH
# ============================================================

if [ -f "$INSTALL_DIR/subscout.sh" ]; then
    echo -e "  ${GREEN}[OK]${NC} SubScout ja esta instalado!"
    echo ""
    sleep 1
    exec bash "$INSTALL_DIR/subscout.sh"
fi

# ============================================================
#   FIRST TIME INSTALL
# ============================================================

echo -e "${YELLOW}[*] Instalando SubScout...${NC}"
echo ""

# --- Dependencies ---
echo -e "${YELLOW}[*] Verificando dependencias...${NC}"
echo ""

DEPS="git dnsutils curl bash"
for dep in $DEPS; do
    if command -v "$dep" > /dev/null 2>&1; then
        echo -e "  ${GREEN}[OK]${NC} $dep"
    else
        echo -e "  ${YELLOW}[*]${NC} Instalando $dep..."
        if [ "$IS_TERMUX" -eq 1 ]; then
            pkg update -y > /dev/null 2>&1
            pkg install -y "$dep" > /dev/null 2>&1
        elif command -v apt > /dev/null 2>&1; then
            sudo apt update -y > /dev/null 2>&1
            sudo apt install -y "$dep" > /dev/null 2>&1
        fi
        if command -v "$dep" > /dev/null 2>&1; then
            echo -e "  ${GREEN}[OK]${NC} $dep"
        else
            echo -e "  ${DARK}[SKIP]${NC} $dep (tente instalar manualmente)"
        fi
    fi
done

# --- Clone repo ---
echo ""
echo -e "${YELLOW}[*] Baixando SubScout...${NC}"
echo ""

echo -e "  ${DARK}[*]${NC} Clonando repositorio..."
if ! git clone "$REPO_URL" "$INSTALL_DIR" 2>&1; then
    echo -e "  ${RED}[ERRO]${NC} Falha ao baixar o projeto."
    echo -e "  ${DARK}Verifique sua conexao com a internet.${NC}"
    exit 1
fi

chmod +x "$INSTALL_DIR/subscout.sh" 2>/dev/null

echo -e "  ${GREEN}[OK]${NC} SubScout instalado em: $INSTALL_DIR"

# --- Create subscout command ---
echo ""
echo -e "${YELLOW}[*] Criando comando 'subscout'...${NC}"
echo ""

NEXUS_BIN="$HOME/.subscout-bin"
mkdir -p "$NEXUS_BIN"

cat > "$NEXUS_BIN/subscout" << WRAPPER
#!/bin/bash
exec bash "$INSTALL_DIR/subscout.sh" "\$@"
WRAPPER
chmod +x "$NEXUS_BIN/subscout"

SHELL_RC=""
[ -f "$HOME/.bashrc" ] && SHELL_RC="$HOME/.bashrc"
[ -f "$HOME/.zshrc" ] && SHELL_RC="$HOME/.zshrc"

if [ -n "$SHELL_RC" ]; then
    if ! grep -q ".subscout-bin" "$SHELL_RC" 2>/dev/null; then
        echo "" >> "$SHELL_RC"
        echo "# SubScout" >> "$SHELL_RC"
        echo 'export PATH="$HOME/.subscout-bin:$PATH"' >> "$SHELL_RC"
    fi
    export PATH="$HOME/.subscout-bin:$PATH"
fi

if [ "$IS_TERMUX" -eq 1 ] && [ -d "$PREFIX/bin" ]; then
    ln -sf "$NEXUS_BIN/subscout" "$PREFIX/bin/subscout" 2>/dev/null
fi

echo -e "  ${GREEN}[OK]${NC} Comando 'subscout' criado"

# --- Done ---
echo ""
echo -e "${CYAN}========================================${NC}"
echo -e "${GREEN}  INSTALACAO COMPLETA!${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""
echo -e "  ${WHITE}Para iniciar a qualquer momento:${NC}"
echo -e "  ${CYAN}subscout${NC}"
echo ""
echo -e "${DARK}Iniciando ferramenta...${NC}"
echo ""

sleep 2

exec bash "$INSTALL_DIR/subscout.sh"
