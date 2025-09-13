#!/bin/bash
is_number() {
    [[ $1 =~ ^[0-9]+$ ]]
}
YELLOW='\033[1;33m'
RED='\033[1;31m'
CYAN='\033[1;36m'
GREEN='\033[1;32m'
NC='\033[0m'
cd /root
apt -y update && apt -y upgrade
apt -y install iptables-persistent wget screen lsof
rm -rf ashdnstt-commercial
mkdir ashdnstt-commercial
cd ashdnstt-commercial
mv /root/ashdnstt-server ashdnstt-server
chmod 755 ashdnstt-server
wget https://raw.githubusercontent.com/ASHANTENNA/VPNScript/main/server.key
wget https://raw.githubusercontent.com/ASHANTENNA/VPNScript/main/server.pub
echo -e "$YELLOW"
cat server.pub
read -p "Copy the pubkey above and press Enter when done"
read -p "Enter your Nameserver : " ns
iptables -I INPUT -p udp --dport 5300 -j ACCEPT
iptables -t nat -I PREROUTING -p udp --dport 53 -j REDIRECT --to-ports 5300
iptables-save > /etc/iptables/rules.v4
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
echo -e "$YELLOW"
read -p "Run in background or foreground service ? (b/f): " bind
echo -e "$NC"
if [ "$bind" = "b" ]; then
    screen -dmS ashdnstt-commercial ./ashdnstt-server -udp :5300 -privkey-file server.key $ns 127.0.0.1:$target_port
else
    json_content=$(cat <<-EOF
[Unit]
Description=Daemonize ASH DNSTT Commercial Tunnel Server
Wants=network.target
After=network.target
[Service]
ExecStart=/root/ashdnstt-commercial/ashdnstt-server -udp :5300 -privkey-file /root/ashdnstt-commercial/server.key $ns 127.0.0.1:$target_port
Restart=always
RestartSec=3
[Install]
WantedBy=multi-user.target
EOF
)
    echo "$json_content" > /etc/systemd/system/ashdnsttcommercial.service
    systemctl start ashdnsttcommercial
    systemctl enable ashdnsttcommercial
fi
lsof -i :5300
echo -e "ASHDNSTT Commercial installation completed"
echo -e "$NC"
