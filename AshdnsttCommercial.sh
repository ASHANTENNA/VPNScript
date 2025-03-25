#!/bin/bash
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
echo -e "$YELLOW"
read -p "Run in background or foreground service ? (b/f): " bind
echo -e "$NC"
if [ "$bind" = "b" ]; then
    screen -dmS ashdnstt-commercial ./ashdnstt-server -udp :5300 -privkey-file server.key $ns 127.0.0.1:22
else
    json_content=$(cat <<-EOF
[Unit]
Description=Daemonize ASH DNSTT Commercial Tunnel Server
Wants=network.target
After=network.target
[Service]
ExecStart=/root/ashdnstt-commercial/ashdnstt-server -udp :5300 -privkey-file /root/ashdnstt-commercial/server.key $ns 127.0.0.1:22
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