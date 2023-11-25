#!/bin/bash
is_number() {
    [[ $1 =~ ^[0-9]+$ ]]
}
YELLOW='\033[1;33m'
NC='\033[0m'
if [ "$(whoami)" != "root" ]; then
    echo "Error: This script must be run as root."
    exit 1
fi
cd /root
clear
echo "  A    SSS   H   H"
echo " A A   S     H   H"
echo "AAAAA  SSS   HHHHH"
echo "A   A      S H   H"
echo "A   A  SSSS  H   H"
echo ""
echo -e "$YELLOW
VPN Tunnel Installer by AhmedSCRIPT Hacker"
echo "Version : 2.0"
echo -e "$NC
Select an option"
echo "1. Install UDP Hysteria V1.3.5"
echo "2. Install UDP Hysteria V2.2.2"
echo "3. Install HTTP Proxy"
echo "4. Install DNSTT, DoH and DoT"
echo "5. Install ADMRufu MOD"
echo "6. Exit"
selected_option=0

while [ $selected_option -lt 1 ] || [ $selected_option -gt 5 ]; do
    echo "Select a number from 1 to 5:"
    read input

    # Check if input is a number
    if [[ $input =~ ^[0-9]+$ ]]; then
        selected_option=$input
    else
        echo "Invalid input. Please enter a valid number."
    fi
done
clear
case $selected_option in
    1)
        echo "Installing UDP Hysteria V1.3.5 ..."
        apt-get update && apt-get upgrade
        apt install wget -y
        apt install nano -y
        apt install net-tools
        mkdir hy
        cd hy
        udp_script="/root/hy/hysteria-linux-amd64"
        if [ ! -e "$udp_script" ]; then
            wget github.com/apernet/hysteria/releases/download/v1.3.5/hysteria-linux-amd64
        fi
        chmod 755 hysteria-linux-amd64
        openssl ecparam -genkey -name prime256v1 -out ca.key
        openssl req -new -x509 -days 36500 -key ca.key -out ca.crt -subj "/CN=bing.com"
        while true; do
            read -p "Obfs : " obfs
            if [ ! -z "$obfs" ]; then
            break
            fi
        done
        while true; do
            read -p "Auth Str : " auth_str
            if [ ! -z "$auth_str" ]; then
            break
            fi
        done
        while true; do
            read -p "Remote UDP Port : " remote_udp_port
            if is_number "$remote_udp_port" && [ "$remote_udp_port" -ge 1 ] && [ "$remote_udp_port" -le 65534 ]; then
                if iptables -t nat -L --line-numbers | grep -q "::'"$remote_udp_port"'"; then
                    echo "Error : the selected port has already been used"
                else
                    break
                fi
            else
                echo "Invalid input. Please enter a valid number between 1 and 65534."
            fi
        done
        file_path="/root/hy/config.json"
        json_content='{"listen":":'"$remote_udp_port"'","protocol":"udp","cert":"/root/hy/ca.crt","key":"/root/hy/ca.key","up":"100 Mbps","up_mbps":100,"down":"100 Mbps","down_mbps":100,"disable_udp":false,"obfs":"'"$obfs"'","auth_str":"'"$auth_str"'"}'
        echo "$json_content" > "$file_path"
        if [ ! -e "$file_path" ]; then
            echo "Error: Unable to save the config.json file"
            exit 1
        fi
        sudo debconf-set-selections <<< "iptables-persistent iptables-persistent/autosave_v4 boolean true"
        sudo debconf-set-selections <<< "iptables-persistent iptables-persistent/autosave_v6 boolean true"
        apt -y install iptables-persistent
        while true; do
            read -p "Binding UDP Ports : from port : " first_number
            if is_number "$first_number" && [ "$first_number" -ge 1 ] && [ "$first_number" -le 65534 ]; then
                break
            else
                echo "Invalid input. Please enter a valid number between 1 and 65534."
            fi
        done
        while true; do
            read -p "Binding UDP Ports : from port : $first_number to port : " second_number
            if is_number "$second_number" && [ "$second_number" -gt "$first_number" ] && [ "$second_number" -lt 65536 ]; then
                break
            else
                echo "Invalid input. Please enter a valid number greater than $first_number and less than 65536."
            fi
        done
        #Remove old rules
        iptables -t nat -L --line-numbers | awk -v var="$first_number:$second_number" '$0 ~ var {print $1}' | tac | xargs -r -I {} iptables -t nat -D PREROUTING {}
        ip6tables -t nat -L --line-numbers | awk -v var="$first_number:$second_number" '$0 ~ var {print $1}' | tac | xargs -r -I {} ip6tables -t nat -D PREROUTING {}
        
        
        iptables -t nat -A PREROUTING -i $(ip -4 route ls|grep default|grep -Po '(?<=dev )(\S+)'|head -1) -p udp --dport "$first_number":"$second_number" -j DNAT --to-destination :36712
        ip6tables -t nat -A PREROUTING -i $(ip -4 route ls|grep default|grep -Po '(?<=dev )(\S+)'|head -1) -p udp --dport "$first_number":"$second_number" -j DNAT --to-destination :36712
        sysctl net.ipv4.conf.all.rp_filter=0
        sysctl net.ipv4.conf.$(ip -4 route ls|grep default|grep -Po '(?<=dev )(\S+)'|head -1).rp_filter=0 
        echo "net.ipv4.ip_forward = 1
        net.ipv4.conf.all.rp_filter=0
        net.ipv4.conf.$(ip -4 route ls|grep default|grep -Po '(?<=dev )(\S+)'|head -1).rp_filter=0" > /etc/sysctl.conf
        sysctl -p
        sudo iptables-save > /etc/iptables/rules.v4
        sudo ip6tables-save > /etc/iptables/rules.v6
        nohup ./hysteria-linux-amd64 server>hysteria.log 2>&1 &
        cat hysteria.log
        echo "UDP Hysteria V1.3.5 installed successfully, please check the logs above"
        echo "IP Address :"
        curl ipv4.icanhazip.com
        echo "Obfs : '"$obfs"'"
        echo "auth str : '"$auth_str"'"
        exit 1
        ;;
    2)
        echo "Installing UDP Hysteria V2.2.2 ..."
        apt-get update && apt-get upgrade
        apt install wget -y
        apt install nano -y
        apt install net-tools
        mkdir hy2
        cd hy2
        udp_script="/root/hy2/hysteria-linux-amd64"
        if [ ! -e "$udp_script" ]; then
            wget github.com/apernet/hysteria/releases/download/v1.3.5/hysteria-linux-amd64
        fi
        chmod 755 hysteria-linux-amd64
        openssl ecparam -genkey -name prime256v1 -out ca.key
        openssl req -new -x509 -days 36500 -key ca.key -out ca.crt -subj "/CN=bing.com"
        while true; do
            read -p "Obfs : " obfs
            if [ ! -z "$obfs" ]; then
            break
            fi
        done
        while true; do
            read -p "Auth Str : " auth_str
            if [ ! -z "$auth_str" ]; then
            break
            fi
        done
        while true; do
            read -p "Remote UDP Port : " remote_udp_port
            if is_number "$remote_udp_port" && [ "$remote_udp_port" -ge 1 ] && [ "$remote_udp_port" -le 65534 ]; then
                if iptables -t nat -L --line-numbers | grep -q "::'"$remote_udp_port"'"; then
                    echo "Error : the selected port has already been used"
                else
                    break
                fi
            else
                echo "Invalid input. Please enter a valid number between 1 and 65534."
            fi
        done
        file_path="/root/hy2/config.yaml"
        json_content=$(cat <<EOF
listen: :$remote_udp_port
tls:
  cert: ca.crt
  key: ca.key
obfs:
  type: salamander
  salamander:
    password: $obfs
quic:
  initStreamReceiveWindow: 16777216
  maxStreamReceiveWindow: 16777216
  initConnReceiveWindow: 33554432
  maxConnReceiveWindow: 33554432
auth:
  type: password
  password: $auth_str
masquerade:
  type: proxy
  proxy:
    url: https://223.5.5.5/dns-query
    rewriteHost: true
EOF
)
        echo "$json_content" > "$file_path"
        if [ ! -e "$file_path" ]; then
            echo "Error: Unable to save the config.json file"
            exit 1
        fi
        
        while true; do
            read -p "Binding UDP Ports : from port : " first_number
            if is_number "$first_number" && [ "$first_number" -ge 1 ] && [ "$first_number" -le 65534 ]; then
                break
            else
                echo "Invalid input. Please enter a valid number between 1 and 65534."
            fi
        done
        while true; do
            read -p "Binding UDP Ports : from port : $first_number to port : " second_number
            if is_number "$second_number" && [ "$second_number" -gt "$first_number" ] && [ "$second_number" -lt 65536 ]; then
                break
            else
                echo "Invalid input. Please enter a valid number greater than $first_number and less than 65536."
            fi
        done
        
        warpv6=$(curl -s6m8 https://www.cloudflare.com/cdn-cgi/trace -k | grep warp | cut -d= -f2)
        warpv4=$(curl -s4m8 https://www.cloudflare.com/cdn-cgi/trace -k | grep warp | cut -d= -f2)
        [[ $warpv4 =~ on|plus || $warpv6 =~ on|plus ]]
        wg-quick down wgcf >/dev/null 2>&1
        systemctl stop warp-go >/dev/null 2>&1
        systemctl start warp-go >/dev/null 2>&1
        wg-quick up wgcf >/dev/null 2>&1

        #Remove old rules
        iptables -t nat -L --line-numbers | awk -v var="$first_number:$second_number" '$0 ~ var {print $1}' | tac | xargs -r -I {} iptables -t nat -D PREROUTING {}
        ip6tables -t nat -L --line-numbers | awk -v var="$first_number:$second_number" '$0 ~ var {print $1}' | tac | xargs -r -I {} ip6tables -t nat -D PREROUTING {}
        
        
        iptables -t nat -A PREROUTING -i $(ip -4 route ls|grep default|grep -Po '(?<=dev )(\S+)'|head -1) -p udp --dport "$first_number":"$second_number" -j DNAT --to-destination :36712
        ip6tables -t nat -A PREROUTING -i $(ip -4 route ls|grep default|grep -Po '(?<=dev )(\S+)'|head -1) -p udp --dport "$first_number":"$second_number" -j DNAT --to-destination :36712
        sysctl net.ipv4.conf.all.rp_filter=0
        sysctl net.ipv4.conf.$(ip -4 route ls|grep default|grep -Po '(?<=dev )(\S+)'|head -1).rp_filter=0 
        echo "net.ipv4.ip_forward = 1
        net.ipv4.conf.all.rp_filter=0
        net.ipv4.conf.$(ip -4 route ls|grep default|grep -Po '(?<=dev )(\S+)'|head -1).rp_filter=0" > /etc/sysctl.conf
        sysctl -p
        sudo iptables-save > /etc/iptables/rules.v4
        sudo ip6tables-save > /etc/iptables/rules.v6
        nohup ./hysteria-linux-amd64 server>hysteria.log 2>&1 &
        cat hysteria.log
        echo "UDP Hysteria V2.2.2 installed successfully, please check the logs above"
        echo "IP Address :"
        curl ipv4.icanhazip.com
        echo "Obfs : '"$obfs"'"
        echo "auth str : '"$auth_stf"'"
        exit 1
    3)
        echo "Installing HTTP Proxy..."
        while true; do
            read -p "Remote HTTP Port : " http_port
            if is_number "$http_port" && [ "$http_port" -ge 1 ] && [ "$http_port" -le 65535 ]; then
                break
            else
                echo "Invalid input. Please enter a valid number between 1 and 65535."
            fi
        done
        mkdir tcp
        cd tcp
        http_script="/root/tcp/sshProxy_linux_amd64"
        if [ ! -e "$http_script" ]; then
            wget https://github.com/CassianoDev/sshProxy/releases/download/v1.1/sshProxy_linux_amd64
        fi
        chmod 755 sshProxy_linux_amd64
        screen -dmS ssh_proxy ./sshProxy_linux_amd64 -addr :"$http_port" dstAddr 127.0.0.1:22
        echo "HTTP Proxy installed successfully"
        exit 1
        ;;
    4)
        echo "Installing DNSTT,DoH and DoT ..."
        apt update
        apt upgrade
        wget https://raw.githubusercontent.com/Torch121/DNSTT/main/installer.sh -O installer.sh && chmod +x installer.sh && ./installer.sh
        exit 1
        ;;
    5)
        echo "When installing, Select ADMRufu"
        rm -rf Install-Sin-Key.sh; apt update; apt upgrade -y; wget https://raw.githubusercontent.com/NetVPS/VPS-MX_Oficial/master/Instalador/Install-Sin-Key.sh; chmod 777 Install-Sin-Key.sh; ./Install-Sin-Key.sh --start
        exit 1
        ;;
    6)
        echo "Exiting..."
        exit 1
        ;;
esac
