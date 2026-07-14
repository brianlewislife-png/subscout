<div align="center">

<img src="https://capsule-render.vercel.app/api?type=waving&color=0:0a0e1a,20:0f172a,40:1e1b4b,60:0f172a,80:0c1222,100:0a0e1a&height=240&section=header&text=SUBSCOUT&fontSize=38&fontColor=00D4FF&fontAlignY=36&animation=fadeIn&desc=Subdomain%20Scanner%20%20%20%202026&descSize=18&descColor=C084FC&descAlignY=62&descAlign=50" width="100%"/>

<br/>

<img src="https://readme-typing-svg.demolab.com?font=JetBrains+Mono&weight=600&size=20&duration=3000&pause=1000&color=00D4FF&center=true&vCenter=true&multiline=true&repeat=true&width=600&height=90&lines=%F0%9F%94%8D+Discover+every+subdomain;%E2%9A%A1+Fast+%C2%B7+Precise+%C2%B7+3500%2B+entries;%F0%9F%94%A7+Built+for+Termux+on+Android" alt="Typing SVG" />

<br/>

[![License: MIT](https://img.shields.io/badge/License-MIT-00D4FF?style=for-the-badge&logo=github&logoColor=white)](https://opensource.org/licenses/MIT)
[![Platform: Termux](https://img.shields.io/badge/Platform-Termux%20(Android)-00D4FF?style=for-the-badge&logo=android&logoColor=white)](https://termux.dev)
[![Shell: Bash](https://img.shields.io/badge/Shell-Bash-00C853?style=for-the-badge&logo=gnubash&logoColor=white)](https://www.gnu.org/software/bash/)

</div>

---

## Overview

**SUBSCOUT** is a fast, lightweight subdomain scanner built for **Termux on Android** and Linux. It uses a comprehensive wordlist with **3500+ entries** to discover hidden subdomains of any target domain.

---

## Features

<table>
<tr>
<td>

- 3500+ subdomain wordlist
- Multiple DNS resolution methods
- Fast / Medium / Full scan modes
- Custom wordlist support
- Real-time progress display
- Automatic result saving
- Results viewer built-in
- Interactive terminal UI
- No external dependencies required

</td>
</tr>
</table>

---

## Quick Install

Open **Termux** and run:

```bash
# Install git if you don't have it
pkg install git dnsutils

# Clone the repository
git clone https://github.com/brianlewislife-png/SubScout.git

# Enter the directory
cd SubScout

# Make executable
chmod +x subscout.sh

# Run
bash subscout.sh
```

---

## Menu

```
========================================
 SUBSCOUT - SUBDOMAIN SCANNER
========================================

[1]  Scan rapido          (500 entradas)
[2]  Scan medio           (1500 entradas)
[3]  Scan completo        (3500+ entradas)
[4]  Scan customizado     (sua wordlist)
[5]  Ver resultados anteriores
[6]  Sobre

[0]  Sair
```

---

## Scan Modes

| Mode | Entries | Speed | Use Case |
|------|---------|-------|----------|
| **Quick** | 500 | Fast | Quick recon |
| **Medium** | 1500 | Balanced | Standard audit |
| **Full** | 3500+ | Thorough | Deep enumeration |
| **Custom** | Any | Variable | Your own wordlist |

---

## Wordlist Categories

The included wordlist (`wordlist.txt`) covers:

- Common subdomains (www, mail, api, etc.)
- Development (dev, staging, test, beta, etc.)
- Infrastructure (cdn, server, node, etc.)
- Security (admin, panel, portal, etc.)
- E-commerce (shop, store, cart, etc.)
- Crypto/Web3 (wallet, exchange, defi, etc.)
- Social/Communication (blog, forum, chat, etc.)
- And 2000+ alphanumeric combinations

---

## Project Structure

```
SubScout/
├── subscout.sh          # Main scanner script
├── wordlist.txt         # 3500+ subdomain wordlist
├── results/             # Scan results (auto-created)
└── README.md            # Documentation
```

---

## Requirements

- **Termux** (latest version from F-Droid) or Linux
- **Bash** 4.0+
- **dnsutils** (`pkg install dnsutils`) for `host`/`dig` commands
- **curl** (optional, fallback method)

> Download Termux: [F-Droid](https://f-droid.org/en/packages/com.termux/) or [GitHub Releases](https://github.com/termux/termux-app/releases)

---

## Development

```bash
# Make executable
chmod +x subscout.sh

# Run directly
./subscout.sh

# Use custom wordlist
./subscout.sh --wordlist /path/to/wordlist.txt --target example.com
```

---

## Contributing

Contributions are welcome. Open an issue or submit a pull request.

---

## License

This project is licensed under the MIT License.

---

<div align="center">

**Developed by Brian Lewis**

[![GitHub](https://img.shields.io/badge/GitHub-181717?style=for-the-badge&logo=github&logoColor=white)](https://github.com/brianlewislife-png)
[![Instagram](https://img.shields.io/badge/Instagram-E4405F?style=for-the-badge&logo=instagram&logoColor=white)](https://instagram.com/Brian_lewis_2)

<br/>

<img src="https://capsule-render.vercel.app/api?type=waving&color=0:0a0e1a,20:0f172a,40:1e1b4b,60:0f172a,80:0c1222,100:0a0e1a&height=80&section=footer" width="100%"/>

</div>
