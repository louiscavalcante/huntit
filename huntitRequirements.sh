#!/bin/bash

set -e

#@> VARIABLES
huntitDIR=`cd "$(dirname "$0")" && pwd`
retries=0

#@> COLORS
GREEN=`tput setaf 2`
RED=`tput setaf 1`
NC=`tput sgr0`

#@> EXIT SCRIPT FUNCTION
trap ctrl_c INT
function ctrl_c() {
  echo -e "\n${RED}[!]${NC} Interrupted, ${GREEN}CTRL${NC}+${GREEN}C${NC} pressed! ${RED}Exiting${NC} huntit..."
  echo -en "\e[?25h"
  exit 0;
}

#@> USAGE GUIDE
usage() {
  echo -e "\n${GREEN}Usage:${NC}"
  echo "   Syntax: ./huntitRequirements.sh ${GREEN}--install${NC}"
  echo ""
  echo "${GREEN}Flags:${NC}"
  echo "   -i,  --install                 Installs huntit required tools"
  echo "   -u,  --update-requirements     Updates huntit required tools"
  echo "   -p,  --update-paths            Re-writes env paths and aliases on ~/.zshrc and ~/.bashrc"
  echo "   -h,  --help                    Help for huntitRequirements.sh"
}

#@> RUNTIME START
start=`date +%s`

#@> PATHS SECTION
pathWriterTask() {
  echo -e "\n${GREEN}[+]${NC} Adding golang paths to ~/.zshrc and ~/.bashrc ..."
  echo -e "\n# GOLANG ENV PATH" >> ~/.zshrc
  echo "export PATH=$PATH:$HOME/go/bin" >> ~/.zshrc
  echo -e "\n# GOLANG ENV PATH" >> ~/.bashrc
  echo "export PATH=$PATH:$HOME/go/bin" >> ~/.bashrc

  echo -e "\n${GREEN}[+]${NC} Adding huntit aliases to ~/.zshrc and ~/.bashrc ..."
  echo -e "\n# HUNTIT ALIAS PATH" >> ~/.zshrc
  echo "alias huntit=$huntitDIR/huntit.sh" >> ~/.zshrc
  echo -e "\n# HUNTIT ALIAS PATH" >> ~/.bashrc
  echo "alias huntit=$huntitDIR/huntit.sh" >> ~/.bashrc
}

#@> TOOLS SECTION
requirementsTask() {
  echo -e "\n${GREEN}[+]${NC} Required tools installation process started..."
  apt update && apt upgrade -y

  echo -e "\n${GREEN}[+]${NC} Installing golang..."
  apt install golang-go

  echo -e "\n${GREEN}[+]${NC} Installing python3..."
  apt install python3

  echo -e "\n${GREEN}[+]${NC} Installing pip3..."
  apt install python3-pip

  echo -e "\n${GREEN}[+]${NC} Installing git..."
  apt install git

  until [ "$retries" -ge 500 ]; do
    echo -e "\n${GREEN}[+]${NC} Installing assetfinder by tomnomnom..."
    /$HOME/go/bin/go get -u github.com/tomnomnom/assetfinder && break
    retries=$((retries+1))
    echo -e "\n${RED}[!]${NC} Retrying installation..."
    sleep 2
  done

  until [ "$retries" -ge 500 ]; do
    echo -e "\n${GREEN}[+]${NC} Installing httprobe by tomnomnom..."
    /$HOME/go/bin/go get -u github.com/tomnomnom/httprobe@master && break
    retries=$((retries+1))
    echo -e "\n${RED}[!]${NC} Retrying installation..."
    sleep 3
  done

  until [ "$retries" -ge 500 ]; do
    echo -e "\n${GREEN}[+]${NC} Installing gowitnessby sensepost..."
    /$HOME/go/bin/go get -u github.com/sensepost/gowitness && break
    retries=$((retries+1))
    echo -e "\n${RED}[!]${NC} Retrying installation..."
    sleep 3
  done

  until [ "$retries" -ge 500 ]; do
    echo -e "\n${GREEN}[+]${NC} Installing waybackurls by tomnomnom..."
    /$HOME/go/bin/go get -u github.com/tomnomnom/waybackurls && break
    retries=$((retries+1))
    echo -e "\n${RED}[!]${NC} Retrying installation..."
    sleep 3
  done

  until [ "$retries" -ge 500 ]; do
    echo -e "\n${GREEN}[+]${NC} Installing paramspider by devanshbatham..."
    if [ ! -d "$huntitDIR"/ThirdPartyTools ]; then
    	mkdir "$huntitDIR"/ThirdPartyTools
    	cd "$huntitDIR"/ThirdPartyTools
    fi
    rm -rf "$huntitDIR"/ThirdPartyTools/ParamSpider
    cd "$huntitDIR"/ThirdPartyTools
    git clone https://github.com/devanshbatham/ParamSpider.git && cd "$huntitDIR" && break
    retries=$((retries+1))
    echo -e "\n${RED}[!]${NC} Retrying installation..."
    sleep 3
  done

  until [ "$retries" -ge 500 ]; do
    echo -e "\n${GREEN}[+]${NC} Installing unfurl by tomnomnom..."
    /$HOME/go/bin/go get -u github.com/tomnomnom/unfurl && break
    retries=$((retries+1))
    echo -e "\n${RED}[!]${NC} Retrying installation..."
    sleep 2
  done

  until [ "$retries" -ge 500 ]; do
    echo -e "\n${GREEN}[+]${NC} Installing gf by tomnomnom..."
    /$HOME/go/bin/go get -u github.com/tomnomnom/gf && break
    retries=$((retries+1))
    echo -e "\n${RED}[!]${NC} Retrying installation..."
    sleep 3
  done

  until [ "$retries" -ge 500 ]; do
    echo -e "\n${GREEN}[+]${NC} Installing Gxss KathanP19..."
    GO111MODULE=on /$HOME/go/bin/go get -v github.com/projectdiscovery/httpx/cmd/httpx && break
    retries=$((retries+1))
    echo -e "\n${RED}[!]${NC} Retrying installation..."
    sleep 3
  done

  until [ "$retries" -ge 500 ]; do
    echo -e "\n${GREEN}[+]${NC} Installing httpx by projectdiscovery..."
    GO111MODULE=on /$HOME/go/bin/go get -v github.com/projectdiscovery/httpx/cmd/httpx && break
    retries=$((retries+1))
    echo -e "\n${RED}[!]${NC} Retrying installation..."
    sleep 2
  done

  until [ "$retries" -ge 500 ]; do
    echo -e "\n${GREEN}[+]${NC} Installing Gxss KathanP19..."
    /$HOME/go/bin/go get -u github.com/KathanP19/Gxss && break
    retries=$((retries+1))
    echo -e "\n${RED}[!]${NC} Retrying installation..."
    sleep 3
  done

  until [ "$retries" -ge 500 ]; do
    echo -e "\n${GREEN}[+]${NC} Installing ffuf by ffuf..."
    /$HOME/go/bin/go get -u github.com/ffuf/ffuf && break
    retries=$((retries+1))
    echo -e "\n${RED}[!]${NC} Retrying installation..."
    sleep 3
  done  

  until [ "$retries" -ge 500 ]; do
    echo -e "\n${GREEN}[+]${NC} Installing gron by tomnomnom..."
    /$HOME/go/bin/go get -u github.com/tomnomnom/gron && break
    retries=$((retries+1))
    echo -e "\n${RED}[!]${NC} Retrying installation..."
    sleep 3
  done

  until [ "$retries" -ge 500 ]; do
    echo -e "\n${GREEN}[+]${NC} Installing meg by tomnomnom..."
    /$HOME/go/bin/go get -u github.com/tomnomnom/meg && break
    retries=$((retries+1))
    echo -e "\n${RED}[!]${NC} Retrying installation..."
    sleep 3
  done

  until [ "$retries" -ge 500 ]; do
    echo -e "\n${GREEN}[+]${NC} Installing dalfox by hahwul..."
    GO111MODULE=on /$HOME/go/bin/go get -v github.com/hahwul/dalfox/v2 && break
    retries=$((retries+1))
    echo -e "\n${RED}[!]${NC} Retrying installation..."
    sleep 3
  done

  echo -e "\n${GREEN}[+]${NC} Installing nmap..."
  apt install nmap

  echo -e "\n${GREEN}[+]${NC} Installing RustScan by RustScan..."
  cd "/tmp"
  curl -s https://github.com/RustScan/RustScan/releases/latest \
| sed 's/.*a href="//; s/">.*//' \
| xargs -n 1 curl \
| grep '/RustScan/RustScan/.*amd64\.deb' \
| sed 's/.*href="/https\:\/\/github.com/; s/" rel=.*//' \
| wget -qi -
  find /tmp -regex '.*rustscan.*' \
| xargs -n 1 dpkg -i
  cd "$huntitDIR"

}

finalInformationsTask() {
  #@> RUNTIME END
  end=`date +%s`
  runtime=$((end-start))

  #@> FINAL INFORMATIONS
  echo -e "\n------------------------------------------------------------------\n"
}

#@> FUNCTIONS CONTROLLER | ON and OFF switches (Respect order)
install() {
  pathWriterTask
  requirementsTask
  finalInformationsTask
  echo "[=] Done: Required tools installation complete. "
  echo -e "[=] Total runtime: ${RED}${runtime}s${NC}"
  echo -e "\n${GREEN}[*]${NC} Please, re-launch your terminal before running huntit!"
  echo "${GREEN}[*]${NC} After the re-launch type: ${GREEN}huntit -h${NC}"
}

update() {
  requirementsTask
  finalInformationsTask
  echo "[=] Done: Required tools update complete. "
  echo -e "[=] Total runtime: ${RED}${runtime}s${NC}"
}

updatePaths() {
  pathWriterTask
  finalInformationsTask
  echo "[=] Done: Env paths and aliases re-written. "
}

#@> USER ARGUMENTS HANDLER
while [ -n "$1" ]; do
  case $1 in
    -i|--install)
	    install
	    shift ;;
    -u|--update-requirements)
      update
	    shift ;;
    -p|--update-paths)
      updatePaths
      shift ;;
    -h|--help)
      usage
      exit 0 ;;
    *)
      echo -e "\n${RED}[-]${NC} You typed an invalid argument!"
      echo "${GREEN}[!]${NC} Please read the usage below."
      usage
      exit 0 ;;
  esac
  shift
done
