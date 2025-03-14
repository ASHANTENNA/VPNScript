#!/bin/bash
is_number() {
    [[ $1 =~ ^[0-9]+$ ]]
}
YELLOW='\033[1;33m'
RED='\033[1;31m'
CYAN='\033[1;36m'
GREEN='\033[1;32m'
NC='\033[0m'
if [ "$(whoami)" != "root" ]; then
    echo "Error: This script must be run as root."
    exit 1
fi
MARKER="### CUSTOM COLOR BLOCK ###"
TEXT_TO_ADD='
'"$MARKER"'
YELLOW='\''\033[1;33m'\''
RED='\''\033[1;31m'\''
CYAN='\''\033[1;36m'\''
GREEN='\''\033[1;32m'\''
NC='\''\033[0m'\''
echo ""
echo -e "$CYAN   A   $YELLOW SSS  $RED H   H"
echo -e "$CYAN  A A  $YELLOW S    $RED H   H"
echo -e "$CYAN AAAAA $YELLOW SSS  $RED HHHHH"
echo -e "$CYAN A   A $YELLOW     S$RED H   H"
echo -e "$CYAN A   A $YELLOW SSSS $RED H   H"
echo "$NC"
'"$MARKER"'
'
if ! grep -Fq "$MARKER" ~/.bashrc; then
    echo "$TEXT_TO_ADD" >> ~/.bashrc
fi
cd /root
clear
echo -e "$CYAN   A   $YELLOW SSS  $RED H   H"
echo -e "$CYAN  A A  $YELLOW S    $RED H   H"
echo -e "$CYAN AAAAA $YELLOW SSS  $RED HHHHH"
echo -e "$CYAN A   A $YELLOW     S$RED H   H"
echo -e "$CYAN A   A $YELLOW SSSS $RED H   H"
echo ""
echo -e "$YELLOW
VPN Tunnel Installer by AhmedSCRIPT Hacker"
echo "Version : 4.4"
echo -e "$NC
Select an option"
echo "1. Install UDP Hysteria V1.3.5"
echo "2. Install UDP Hysteria V2.3.0"
echo "3. Install ASH HTTP Proxy"
echo "4. Install DNSTT, DoH and DoT"
echo "5. Install VPS AGN"
echo "6. Install DNS2TCP"
echo "7. Install WS(port 8080)"
echo "8. Install BadVPN UDPGW(port 7300)"
echo "9. Install ASH SSL"
echo "0. Exit"
selected_option=-1

while [ $selected_option -lt 0 ] || [ $selected_option -gt 9 ]; do
    echo -e "$YELLOW"
    echo "Select a number from 0 to 9:"
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
        apt -y update && apt -y upgrade
        apt -y install wget nano net-tools openssl iptables-persistent screen lsof
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
                break
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

        echo -e "$YELLOW"
        read -p "Bind multiple UDP Ports? (y/n): " bind
        echo -e "$NC"
        if [ "$bind" = "y" ]; then
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
        fi
        sysctl net.ipv4.conf.all.rp_filter=0
        sysctl net.ipv4.conf.$(ip -4 route ls|grep default|grep -Po '(?<=dev )(\S+)'|head -1).rp_filter=0 
        echo "net.ipv4.ip_forward = 1
        net.ipv4.conf.all.rp_filter=0
        net.ipv4.conf.$(ip -4 route ls|grep default|grep -Po '(?<=dev )(\S+)'|head -1).rp_filter=0" > /etc/sysctl.conf
        sysctl -p
        iptables-save > /etc/iptables/rules.v4
        ip6tables-save > /etc/iptables/rules.v6
        echo -e "$YELLOW"
        read -p "Run in background or foreground service ? (b/f): " bind
        echo -e "$NC"
        if [ "$bind" = "b" ]; then
            screen -dmS hy ./hysteria-linux-amd64 server --log-level 0
        else
            json_content=$(cat <<-EOF
[Unit]
Description=Daemonize UDP Hysteria V1 Tunnel Server
Wants=network.target
After=network.target
[Service]
ExecStart=/root/hy/hysteria-linux-amd64 server -c /root/hy/config.json --log-level 0
Restart=always
RestartSec=3
[Install]
WantedBy=multi-user.target
EOF
)
            echo "$json_content" > /etc/systemd/system/hy.service
            systemctl start hy
            systemctl enable hy
        fi
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
        apt -y update && apt -y upgrade
        apt -y install wget nano net-tools openssl iptables-persistent screen lsof
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
                break
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

        echo -e "$YELLOW"
        read -p "Bind multiple UDP Ports? (y/n): " bind
        echo -e "$NC"
        if [ "$bind" = "y" ]; then
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
            iptables-save > /etc/iptables/rules.v4
            ip6tables-save > /etc/iptables/rules.v6
        fi
        
        warpv6=$(curl -s6m8 https://www.cloudflare.com/cdn-cgi/trace -k | grep warp | cut -d= -f2)
        warpv4=$(curl -s4m8 https://www.cloudflare.com/cdn-cgi/trace -k | grep warp | cut -d= -f2)
        [[ $warpv4 =~ on|plus || $warpv6 =~ on|plus ]]
        wg-quick down wgcf >/dev/null 2>&1
        systemctl stop warp-go >/dev/null 2>&1
        systemctl start warp-go >/dev/null 2>&1
        wg-quick up wgcf >/dev/null 2>&1
        
        sysctl net.ipv4.conf.all.rp_filter=0
        sysctl net.ipv4.conf.$(ip -4 route ls|grep default|grep -Po '(?<=dev )(\S+)'|head -1).rp_filter=0 
        echo "net.ipv4.ip_forward = 1
        net.ipv4.conf.all.rp_filter=0
        net.ipv4.conf.$(ip -4 route ls|grep default|grep -Po '(?<=dev )(\S+)'|head -1).rp_filter=0" > /etc/sysctl.conf
        sysctl -p

        echo -e "$YELLOW"
        read -p "Run in background or foreground service ? (b/f): " bind
        echo -e "$NC"
        if [ "$bind" = "b" ]; then
            screen -dmS hy2 ./hysteria-linux-amd64 server
        else
            json_content=$(cat <<-EOF
[Unit]
Description=Daemonize UDP Hysteria V2 Tunnel Server
Wants=network.target
After=network.target
[Service]
ExecStart=/root/hy2/hysteria-linux-amd64 server -c /root/hy2/config.yaml
Restart=always
RestartSec=3
[Install]
WantedBy=multi-user.target
EOF
)
            echo "$json_content" > /etc/systemd/system/hy2.service
            systemctl start hy2
            systemctl enable hy2
        fi

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
        apt -y update && apt -y upgrade
        apt -y install iptables-persistent wget screen lsof
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
            iptables-save > /etc/iptables/rules.v4
        fi
        rm -rf ashhttp
        mkdir ashhttp
        cd ashhttp
        http_script="/root/ashhttp/ashhttpproxy-linux-amd64"
        wget https://raw.githubusercontent.com/ASHANTENNA/VPNScript/main/ashhttpproxy-linux-amd64
        chmod 755 ashhttpproxy-linux-amd64

        echo -e "$YELLOW"
        read -p "Run in background or foreground service ? (b/f): " bind
        echo -e "$NC"
        if [ "$bind" = "b" ]; then
            screen -dmS ashhttp ./ashhttpproxy-linux-amd64 -addr :"$http_port" dstAddr 127.0.0.1:22
        else
            json_content=$(cat <<-EOF
[Unit]
Description=Daemonize ASH HTTP Tunnel Server
Wants=network.target
After=network.target
[Service]
ExecStart=/root/ashhttp/ashhttpproxy-linux-amd64 -addr :"$http_port" dstAddr 127.0.0.1:22
Restart=always
RestartSec=3
[Install]
WantedBy=multi-user.target
EOF
)
            echo "$json_content" > /etc/systemd/system/ashhttp.service
            systemctl start ashhttp
            systemctl enable ashhttp
        fi

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
        apt -y update && apt -y upgrade
        apt -y install iptables-persistent wget screen lsof
        rm -rf dnstt
        mkdir dnstt
        cd dnstt
        wget https://raw.githubusercontent.com/ASHANTENNA/VPNScript/main/dnstt-server
        chmod 755 dnstt-server
        wget https://raw.githubusercontent.com/ASHANTENNA/VPNScript/main/server.key
        wget https://raw.githubusercontent.com/ASHANTENNA/VPNScript/main/server.pub
        echo -e "$YELLOW"
        cat server.pub
        read -p "Copy the pubkey above and press Enter when done"
        read -p "Enter your Nameserver : " ns
        iptables -I INPUT -p udp --dport 5300 -j ACCEPT
        iptables -t nat -I PREROUTING -p udp --dport 53 -j REDIRECT --to-ports 5300
        iptables-save > /etc/iptables/rules.v4

        echo -e "$YELLOW"
        read -p "Run in background or foreground service ? (b/f): " bind
        echo -e "$NC"
        if [ "$bind" = "b" ]; then
            screen -dmS slowdns ./dnstt-server -udp :5300 -privkey-file server.key $ns 127.0.0.1:22
        else
            json_content=$(cat <<-EOF
[Unit]
Description=Daemonize DNSTT Tunnel Server
Wants=network.target
After=network.target
[Service]
ExecStart=/root/dnstt/dnstt-server -udp :5300 -privkey-file /root/dnstt/server.key $ns 127.0.0.1:22
Restart=always
RestartSec=3
[Install]
WantedBy=multi-user.target
EOF
)
            echo "$json_content" > /etc/systemd/system/dnstt.service
            systemctl start dnstt
            systemctl enable dnstt
        fi

        lsof -i :5300
        echo -e "DNSTT installation completed"
        echo -e "$NC"
        exit 1
        ;;
    5)
        echo -e "$YELLOW"
        echo "No longer available"
        echo -e "$NC"
        exit 1
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
        apt -y update && apt -y upgrade
        apt -y install screen lsof dns2tcp nano
        echo -e "$YELLOW"
        read -p "In this step, you will uncomment DNS and write DNS=1.1.1.1 and uncomment DNSStubListener and write DNSStubListener=no"
        echo -e "$NC"
        nano /etc/systemd/resolved.conf
        echo -e "$YELLOW"
        read -p "by tapping 'Enter', you make sure that you have uncomment DNS=1.1.1.1 and DNSStubListener=no"
        echo -e "$NC"
        systemctl restart systemd-resolved
        mkdir dns2tcp
        cd dns2tcp
        mkdir /var/empty
        mkdir /var/empty/dns2tcp
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

        echo -e "$YELLOW"
        read -p "Run in background or foreground service ? (b/f): " bind
        echo -e "$NC"
        if [ "$bind" = "b" ]; then
            dns2tcpd -d 1 -f dns2tcpdrc
        else
            json_content=$(cat <<-EOF
[Unit]
Description=Daemonize DNS2TCP Tunnel Server
Wants=network.target
After=network.target
[Service]
ExecStart=/usr/bin/dns2tcpd -d 1 -F -f /root/dns2tcp/dns2tcpdrc
Restart=always
RestartSec=3
[Install]
WantedBy=multi-user.target
EOF
)
            echo "$json_content" > /etc/systemd/system/dns2tcp.service
            systemctl start dns2tcp
            systemctl enable dns2tcp
        fi
        echo -e "$YELLOW"
        read -p "in the next step, add nameserver 1.1.1.1 to the coming file if there is only nameserver 127.0.0.1 or nameserver 127.0.0.53"
        echo -e "$NC"
        nano /etc/resolv.conf
        echo -e "$YELLOW"
        read -p "by tapping 'Enter', you make sure that you have added nameserver 1.1.1.1"
        echo -e "$YELLOW"
        lsof -i :53
        echo "DNS2TCP server installed sucessfully"
        echo -e "$NC"
        ;;
    7)
        echo -e "$YELLOW"
        echo "Installing WS..."
        echo -e "$NC"
        apt -y update && apt -y upgrade
        apt -y install iptables-persistent wget lsof
        
        rm -rf ashwebsocket
        mkdir ashwebsocket
        cd ashwebsocket
        http_script="/root/ashhttp/ashwebsocket-linux-amd64"
        wget https://raw.githubusercontent.com/ASHANTENNA/VPNScript/main/ashwebsocket-linux-amd64
        chmod 755 ashwebsocket-linux-amd64
        json_content=$(cat <<-EOF
[Unit]
Description=Daemonize ASH Websocket Tunnel Server
Wants=network.target
After=network.target
[Service]
ExecStart=/root/ashwebsocket/ashwebsocket-linux-amd64
Restart=always
RestartSec=3
[Install]
WantedBy=multi-user.target
EOF
)
        echo "$json_content" > /etc/systemd/system/ashwebsocket.service
        systemctl start ashwebsocket
        systemctl enable ashwebsocket

        echo -e "$YELLOW"
        read -p "Bind port 80 too ? (y/n): " bind
        echo -e "$NC"
        if [ "$bind" = "y" ]; then
            iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 8080
            iptables-save > /etc/iptables/rules.v4
        fi
        lsof -i :8080
        echo -e "$YELLOW"
        echo "WS installed sucessfully"
        echo -e "$NC"
        ;;
    8)
        echo -e "$YELLOW"
        echo "Installing BadVPN UDPGW..."
        echo -e "$NC"
        apt -y update && apt -y upgrade
        apt -y install wget lsof
        rm -r badvpn
        mkdir badvpn
        cd badvpn
        wget https://raw.githubusercontent.com/ASHANTENNA/VPNScript/main/badvpn-udpgw
        chmod 755 badvpn-udpgw
        json_content=$(cat <<-EOF
[Unit]
Description=Daemonize BadVPN UDPGW Server
Wants=network.target
After=network.target
[Service]
ExecStart=/root/badvpn/badvpn-udpgw --listen-addr 127.0.0.1:7300 --max-clients 1000 --max-connections-for-client 10 --loglevel 0
Restart=always
RestartSec=3
[Install]
WantedBy=multi-user.target
EOF
)
        echo "$json_content" > /etc/systemd/system/badvpn.service
        systemctl start badvpn
        systemctl enable badvpn
        lsof -i :7300
        echo -e "$YELLOW"
        echo "BadVPN UDPGW Installed Successfully"
        echo -e "$NC"
        exit 1
        ;;
    9)
        echo -e "$YELLOW"
        echo "Installing ASH SSL..."
        echo -e "$NC"
        apt -y update && apt -y upgrade
        apt -y install openssl lsof screen
        while true; do
            echo -e "$YELLOW"
            read -p "Remote SSL Port : " ssl_port
            echo -e "$NC"
            if is_number "$ssl_port" && [ "$ssl_port" -ge 1 ] && [ "$ssl_port" -le 65535 ]; then
                break
            else
                echo -e "$YELLOW"
                echo "Invalid input. Please enter a valid number between 1 and 65535."
                echo -e "$NC"
            fi
        done
        while true; do
            echo -e "$YELLOW"
            read -p "Target TCP Port : " target_port
            echo -e "$NC"
            if is_number "$target_port" && [ "$target_port" -ge 1 ] && [ "$target_port" -le 65535 ]; then
                break
            else
                echo -e "$YELLOW"
                echo "Invalid input. Please enter a valid number between 1 and 65535."
                echo -e "$NC"
            fi
        done
        rm -rf ashssl
        mkdir ashssl
        cd ashssl
        wget https://raw.githubusercontent.com/ASHANTENNA/VPNScript/main/ashsslproxy-linux-amd64
        chmod 755 ashsslproxy-linux-amd64
        openssl genrsa -out stunnel.key 2048
        openssl req -new -key stunnel.key -x509 -days 1000 -out stunnel.crt
        cat stunnel.crt stunnel.key > stunnel.pem
        rm -rf stunnel.crt
        echo -e "$YELLOW"
        read -p "Run in background or foreground service ? (b/f): " bind
        echo -e "$NC"
        if [ "$bind" = "b" ]; then
            screen -dmS ashssl ./ashsslproxy-linux-amd64 -tls_addr :$ssl_port -dstAddr 127.0.0.1:$target_port -private_key stunnel.pem -public_key stunnel.key
        else
            json_content=$(cat <<-EOF
[Unit]
Description=Daemonize ASH SSL Tunnel Server
Wants=network.target
After=network.target
[Service]
ExecStart=/root/ashssl/ashsslproxy-linux-amd64 -tls_addr :$ssl_port -dstAddr 127.0.0.1:$target_port -private_key /root/ashssl/stunnel.pem -public_key /root/ashssl/stunnel.key
Restart=always
RestartSec=3
[Install]
WantedBy=multi-user.target
EOF
)
            echo "$json_content" > /etc/systemd/system/ashssl.service
            systemctl start ashssl
            systemctl enable ashssl
        fi
        lsof -i :"$ssl_port"
        echo -e "$YELLOW"
        echo "ASH SSL Installed Successfully"
        echo -e "$NC"
        exit 1
        ;;
    0)
        echo -e "$YELLOW"
        echo "Good Bye"
        echo -e "$NC"
        exit 1
        ;;
esac
