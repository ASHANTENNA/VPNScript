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
echo "Version : 2.9"
echo -e "$NC
Select an option"
echo "1. Install UDP Hysteria V1.3.5"
echo "2. Install UDP Hysteria V2.3.0"
echo "3. Install ASH HTTP Proxy"
echo "4. Install DNSTT, DoH and DoT"
echo "5. Install VPS AGN"
echo "6. Install DNS2TCP"
echo "7. Exit"
selected_option=0

while [ $selected_option -lt 1 ] || [ $selected_option -gt 7 ]; do
    echo -e "$YELLOW"
    echo "Select a number from 1 to 7:"
    echo -e "$NC"
    read input

    # Check if input is a number
    if [[ $input =~ ^[0-9]+$ ]]; then
        selected_option=$input
    else
        echo -e "$YELLOW"
        echo "Invalid input. Please enter a valid number."
        echo -e "$NC"
    fi
done
clear
case $selected_option in
    1)
        echo -e "$YELLOW"
        echo "Installing UDP Hysteria V1.3.5 ..."
        echo -e "$NC"
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
            echo -e "$YELLOW"
            read -p "Obfs : " obfs
            echo -e "$NC"
            if [ ! -z "$obfs" ]; then
            break
            fi
        done
        while true; do
            echo -e "$YELLOW"
            read -p "Auth Str : " auth_str
            echo -e "$NC"
            if [ ! -z "$auth_str" ]; then
            break
            fi
        done
        while true; do
            echo -e "$YELLOW"
            read -p "Remote UDP Port : " remote_udp_port
            echo -e "$NC"
            if is_number "$remote_udp_port" && [ "$remote_udp_port" -ge 1 ] && [ "$remote_udp_port" -le 65534 ]; then
                if netstat -tulnp | grep -q "::$remote_udp_port"; then
                    echo -e "$YELLOW"
                    echo "Error : the selected port has already been used"
                    echo -e "$NC"
                else
                    break
                fi
            else
                echo -e "$YELLOW"
                echo "Invalid input. Please enter a valid number between 1 and 65534."
                echo -e "$NC"
            fi
        done
        file_path="/root/hy/config.json"
        json_content='{"listen":":'"$remote_udp_port"'","protocol":"udp","cert":"/root/hy/ca.crt","key":"/root/hy/ca.key","up":"100 Mbps","up_mbps":100,"down":"100 Mbps","down_mbps":100,"disable_udp":false,"obfs":"'"$obfs"'","auth_str":"'"$auth_str"'"}'
        echo "$json_content" > "$file_path"
        if [ ! -e "$file_path" ]; then
            echo -e "$YELLOW"
            echo "Error: Unable to save the config.json file"
            echo -e "$NC"
            exit 1
        fi
        sudo debconf-set-selections <<< "iptables-persistent iptables-persistent/autosave_v4 boolean true"
        sudo debconf-set-selections <<< "iptables-persistent iptables-persistent/autosave_v6 boolean true"
        apt -y install iptables-persistent
        while true; do
            echo -e "$YELLOW"
            read -p "Binding UDP Ports : from port : " first_number
            echo -e "$NC"
            if is_number "$first_number" && [ "$first_number" -ge 1 ] && [ "$first_number" -le 65534 ]; then
                break
            else
                echo -e "$YELLOW"
                echo "Invalid input. Please enter a valid number between 1 and 65534."
                echo -e "$NC"
            fi
        done
        while true; do
            echo -e "$YELLOW"
            read -p "Binding UDP Ports : from port : $first_number to port : " second_number
            echo -e "$NC"
            if is_number "$second_number" && [ "$second_number" -gt "$first_number" ] && [ "$second_number" -lt 65536 ]; then
                break
            else
                echo -e "$YELLOW"
                echo "Invalid input. Please enter a valid number greater than $first_number and less than 65536."
                echo -e "$NC"
            fi
        done
        #Remove old rules
        iptables -t nat -L --line-numbers | awk -v var="$first_number:$second_number" '$0 ~ var {print $1}' | tac | xargs -r -I {} iptables -t nat -D PREROUTING {}
        ip6tables -t nat -L --line-numbers | awk -v var="$first_number:$second_number" '$0 ~ var {print $1}' | tac | xargs -r -I {} ip6tables -t nat -D PREROUTING {}
        
        
        iptables -t nat -A PREROUTING -i $(ip -4 route ls|grep default|grep -Po '(?<=dev )(\S+)'|head -1) -p udp --dport "$first_number":"$second_number" -j DNAT --to-destination :$remote_udp_port
        ip6tables -t nat -A PREROUTING -i $(ip -4 route ls|grep default|grep -Po '(?<=dev )(\S+)'|head -1) -p udp --dport "$first_number":"$second_number" -j DNAT --to-destination :$remote_udp_port
        sysctl net.ipv4.conf.all.rp_filter=0
        sysctl net.ipv4.conf.$(ip -4 route ls|grep default|grep -Po '(?<=dev )(\S+)'|head -1).rp_filter=0 
        echo "net.ipv4.ip_forward = 1
        net.ipv4.conf.all.rp_filter=0
        net.ipv4.conf.$(ip -4 route ls|grep default|grep -Po '(?<=dev )(\S+)'|head -1).rp_filter=0" > /etc/sysctl.conf
        sysctl -p
        sudo iptables-save > /etc/iptables/rules.v4
        sudo ip6tables-save > /etc/iptables/rules.v6
        screen -dmS hy ./hysteria-linux-amd64 server --log-level 0
        lsof -i :"$remote_udp_port"
        echo "UDP Hysteria V1.3.5 installed successfully, please check the logs above"
        echo "IP Address :"
        curl ipv4.icanhazip.com
        echo "Obfs : '"$obfs"'"
        echo "auth str : '"$auth_str"'"
        exit 1
        ;;
    2)
        echo -e "$YELLOW"
        echo "Installing UDP Hysteria V2.3.0 ..."
        echo -e "$NC"
        apt-get update && apt-get upgrade
        apt install wget -y
        apt install nano -y
        apt install net-tools
        mkdir hy2
        cd hy2
        udp_script="/root/hy2/hysteria-linux-amd64"
        if [ ! -e "$udp_script" ]; then
            wget github.com/apernet/hysteria/releases/download/app/v2.3.0/hysteria-linux-amd64
        fi
        chmod 755 hysteria-linux-amd64
        openssl ecparam -genkey -name prime256v1 -out ca.key
        openssl req -new -x509 -days 36500 -key ca.key -out ca.crt -subj "/CN=bing.com"
        while true; do
            echo -e "$YELLOW"
            read -p "Obfs : " obfs
            echo -e "$NC"
            if [ ! -z "$obfs" ]; then
            break
            fi
        done
        while true; do
            echo -e "$YELLOW"
            read -p "Auth Str : " auth_str
            echo -e "$NC"
            if [ ! -z "$auth_str" ]; then
            break
            fi
        done
        while true; do
            echo -e "$YELLOW"
            read -p "Remote UDP Port : " remote_udp_port
            echo -e "$NC"
            if is_number "$remote_udp_port" && [ "$remote_udp_port" -ge 1 ] && [ "$remote_udp_port" -le 65534 ]; then
                if netstat -tulnp | grep -q "::$remote_udp_port"; then
                    echo -e "$YELLOW"
                    echo "Error : the selected port has already been used"
                    echo -e "$NC"
                else
                    break
                fi
            else
                echo -e "$YELLOW"
                echo "Invalid input. Please enter a valid number between 1 and 65534."
                echo -e "$NC"
            fi
        done
        file_path="/root/hy2/config.yaml"
        json_content=$(cat <<-EOF
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
            echo -e "$YELLOW"
            echo "Error: Unable to save the config.json file"
            echo -e "$NC"
            exit 1
        fi
        
        while true; do
            echo -e "$YELLOW"
            read -p "Binding UDP Ports : from port : " first_number
            echo -e "$NC"
            if is_number "$first_number" && [ "$first_number" -ge 1 ] && [ "$first_number" -le 65534 ]; then
                break
            else
                echo -e "$YELLOW"
                echo "Invalid input. Please enter a valid number between 1 and 65534."
                echo -e "$NC"
            fi
        done
        while true; do
            echo -e "$YELLOW"
            read -p "Binding UDP Ports : from port : $first_number to port : " second_number
            echo -e "$NC"
            if is_number "$second_number" && [ "$second_number" -gt "$first_number" ] && [ "$second_number" -lt 65536 ]; then
                break
            else
                echo -e "$YELLOW"
                echo "Invalid input. Please enter a valid number greater than $first_number and less than 65536."
                echo -e "$NC"
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
        
        
        iptables -t nat -A PREROUTING -i $(ip -4 route ls|grep default|grep -Po '(?<=dev )(\S+)'|head -1) -p udp --dport "$first_number":"$second_number" -j DNAT --to-destination :$remote_udp_port
        ip6tables -t nat -A PREROUTING -i $(ip -4 route ls|grep default|grep -Po '(?<=dev )(\S+)'|head -1) -p udp --dport "$first_number":"$second_number" -j DNAT --to-destination :$remote_udp_port
        sysctl net.ipv4.conf.all.rp_filter=0
        sysctl net.ipv4.conf.$(ip -4 route ls|grep default|grep -Po '(?<=dev )(\S+)'|head -1).rp_filter=0 
        echo "net.ipv4.ip_forward = 1
        net.ipv4.conf.all.rp_filter=0
        net.ipv4.conf.$(ip -4 route ls|grep default|grep -Po '(?<=dev )(\S+)'|head -1).rp_filter=0" > /etc/sysctl.conf
        sysctl -p
        sudo iptables-save > /etc/iptables/rules.v4
        sudo ip6tables-save > /etc/iptables/rules.v6
        screen -dmS hy2 ./hysteria-linux-amd64 server --log-level 0
        lsof -i :"$remote_udp_port"
        echo -e "$YELLOW"
        echo "UDP Hysteria V2.3.0 installed successfully, please check the logs above"
        echo "IP Address :"
        curl ipv4.icanhazip.com
        echo "Obfs : '"$obfs"'"
        echo "auth str : '"$auth_str"'"
        echo -e "$NC"
        exit 1
        ;;
    3)
        echo -e "$YELLOW"
        echo "Installing ASH HTTP Proxy..."
        echo -e "$NC"
        while true; do
            echo -e "$YELLOW"
            read -p "Remote HTTP Port : " http_port
            echo -e "$NC"
            if is_number "$http_port" && [ "$http_port" -ge 1 ] && [ "$http_port" -le 65535 ]; then
                break
            else
                echo -e "$YELLOW"
                echo "Invalid input. Please enter a valid number between 1 and 65535."
                echo -e "$NC"
            fi
        done
        echo -e "$YELLOW"
        read -p "Bind multiple TCP Ports? (y/n): " bind
        echo -e "$NC"
        if [ "$bind" = "y" ]; then
            while true; do
            echo -e "$YELLOW"
            read -p "Binding TCP Ports : from port : " first_number
            echo -e "$NC"
            if is_number "$first_number" && [ "$first_number" -ge 1 ] && [ "$first_number" -le 65534 ]; then
                break
            else
                echo -e "$YELLOW"
                echo "Invalid input. Please enter a valid number between 1 and 65534."
                echo -e "$NC"
            fi
        done
        while true; do
            echo -e "$YELLOW"
            read -p "Binding TCP Ports : from port : $first_number to port : " second_number
            echo -e "$NC"
            if is_number "$second_number" && [ "$second_number" -gt "$first_number" ] && [ "$second_number" -lt 65536 ]; then
                break
            else
                echo -e "$YELLOW"
                echo "Invalid input. Please enter a valid number greater than $first_number and less than 65536."
                echo -e "$NC"
            fi
        done
        iptables -t nat -A PREROUTING -p tcp --dport "$first_number":"$second_number" -j REDIRECT --to-port "$http_port"
        fi
        mkdir ashhttp
        cd ashhttp
        http_script="/root/ashhttp/ashhtttpproxy-linux-amd64"
        if [ ! -e "$http_script" ]; then
            #wget https://github.com/CassianoDev/sshProxy/releases/download/v1.1/sshProxy_linux_amd64
            wget https://raw.githubusercontent.com/ASHANTENNA/VPNScript/main/ashhttpproxy-linux-amd64
        fi
        chmod 755 ashhttpproxy-linux-amd64
        screen -dmS ashhttp ./ashhttpproxy-linux-amd64 -addr :"$http_port" dstAddr 127.0.0.1:22
        lsof -i :"$http_port"
        echo -e "$YELLOW"
        echo "ASH HTTP Proxy installed successfully"
        echo -e "$NC"
        exit 1
        ;;
    4)
        echo -e "$YELLOW"
        echo "Installing DNSTT,DoH and DoT ..."
        echo -e "$NC"
        apt update
        apt upgrade
        mkdir dnstt
        cd dnstt
        if [ ! -e "dnstt-server" ]; then
            wget https://raw.githubusercontent.com/ASHANTENNA/VPNScript/main/dnstt-server
        fi
        chmod 755 dnstt-server
        if [ -e "server.key" ]; then
            rm server.key
        fi
        if [ -e "server.pub" ]; then
            rm server.pub
        fi
        wget https://raw.githubusercontent.com/ASHANTENNA/VPNScript/main/server.key
        wget https://raw.githubusercontent.com/ASHANTENNA/VPNScript/main/server.pub
        echo -e "$YELLOW"
        cat server.pub
        read -p "Copy the pubkey above and press Enter when done"
        read -p "Enter your Nameserver : " ns
        iptables -I INPUT -p udp --dport 5300 -j ACCEPT
        iptables -t nat -I PREROUTING -p udp --dport 53 -j REDIRECT --to-ports 5300
        screen -dmS slowdns ./dnstt-server -udp :5300 -privkey-file server.key $ns 127.0.0.1:22
        lsof -i :5300
        echo -e "DNSTT installation completed"
        echo -e "$NC"
        exit 1
        ;;
    5)
        echo -e "$YELLOW"
        echo "While installing, Select x8.5"
        echo -e "$NC"
        rm -rf install-without-key.sh; apt update; apt install curl; apt install bc; wget https://github.com/khaledagn/VPS-AGN_English_Official/raw/main/installer/install-without-key.sh; chmod 777 install-without-key.sh; ./install-without-key.sh --start
        exit 1
        ;;
    6)
        echo -e "$YELLOW"
        echo -e "Before you continue, make sure that :"
        echo -e "- No program uses UDP Port 53"
        echo -e "- DNSTT is not running"
        echo -e "- iodine is not running"
        echo -e "- iptables doesn't forward the port 53 to another port"
        echo -e "$NC"
        read
        apt-get install dns2tcp
        echo -e "$YELLOW"
        read -p "In this step, you will uncomment DNS and write DNS=1.1.1.1 and uncomment DNSStubListener and write DNSStubListener=no"
        echo -e "$NC"
        nano /etc/systemd/resolved.conf
        echo -e "$YELLOW"
        read -p "by tapping 'Enter', you make sure that you have uncomment DNS=1.1.1.1 and DNSStubListener=no"
        echo -e "$NC"
        if lsof -i :53 | grep -q ":53"; then
            echo -e "$YELLOW"
            echo "Error : there is a program that already uses the port 53"
            echo -e "$NC"
            exit 1
        fi
        systemctl restart systemd-resolved
        mkdir dns2tcp
        cd dns2tcp
        mkdir /var/empty
        mkdir /var/empty/dns2tcp
        adduser ashtunnel
        echo -e "$YELLOW"
        read -p "Your Nameserver: " nameserver
        read -p "Your key: " key
        echo -e "$NC"
        file_path="/root/dns2tcp/dns2tcpdrc"
        json_content=$(cat <<EOF
listen = 0.0.0.0
port = 53
user = ashtunnel
chroot = /var/empty/dns2tcp/
domain = $nameserver
key = $key
resources = ssh:127.0.0.1:22
EOF
)
        echo "$json_content" > "$file_path"
        dns2tcpd -d 1 -f dns2tcpdrc
        lsof -i :53
        echo -e "$YELLOW"
        read -p "in the next step, add nameserver 8.8.8.8 to the coming file if there is only nameserver 127.0.0.1 or nameserver 127.0.0.53"
        echo -e "$NC"
        nano /etc/resolv.conf
        echo -e "$YELLOW"
        read -p "by tapping 'Enter', you make sure that you have added nameserver 8.8.8.8"
        echo -e "$YELLOW"
        echo "DNS2TCP server installed"
        echo -e "$NC"
        ;;
    7)
        echo -e "$YELLOW"
        echo "Good Bye"
        echo -e "$NC"
        exit 1
        ;;
esac
