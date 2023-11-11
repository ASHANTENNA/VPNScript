is_number() {
    [[ $1 =~ ^[0-9]+$ ]]
}
if [ "$(whoami)" != "root" ]; then
    echo "Error: This script must be run as root."
    exit 1
fi
cd /root
echo "Script Installer by AhmedSCRIPT Hacker"
echo ""
echo "Select an option"
echo "1. Install UDP Hysteria V1.3.5"
echo "2. Install HTTP Proxy"
echo "3. Install DNSTT, DoH and DoT"
echo "4. Install ADMRufu MOD"
echo "5. Exit"
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
# Perform actions based on the selected option outside the loop
case $selected_option in
    1)
        echo "Installing UDP Hysteria V1.3.5 ..."
        apt-get update && apt-get upgrade
        apt install wget -y
        apt install nano -y
        apt install net-tools
        mkdir hy
        cd hy
        wget github.com/apernet/hysteria/releases/download/v1.3.5/hysteria-linux-amd64
        chmod 755 hysteria-linux-amd64
        openssl ecparam -genkey -name prime256v1 -out ca.key
        openssl req -new -x509 -days 36500 -key ca.key -out ca.crt -subj "/CN=bing.com"
        file_path="/root/hy/config.json"
        json_content='{"listen":":36712","protocol":"udp","cert":"/root/hy/ca.crt","key":"/root/hy/ca.key","up":"100 Mbps","up_mbps":100,"down":"100 Mbps","down_mbps":100,"disable_udp":false,"obfs":"ahmedscript","auth_str":"ahmedscript"}'
        echo "$json_content" > "$file_path"
        if [ -e "$file_path" ]; then
            
        else
            echo "Error: Unable to save the config.json file"
            exit 1
        fi
        sudo debconf-set-selections <<< "iptables-persistent iptables-persistent/autosave_v4 boolean true"
        sudo debconf-set-selections <<< "iptables-persistent iptables-persistent/autosave_v6 boolean true"
        apt -y install iptable
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
        ;;
    2)
        echo "Performing action for option 2."
        # Add your action for option 2 here
        ;;
    3)
        echo "Performing action for option 3."
        # Add your action for option 3 here
        ;;
    4)
        echo "Performing action for option 4."
        # Add your action for option 4 here
        ;;
    5)
        echo "Performing action for option 5. Exiting the script."
        # Add your action for option 5 here
        exit  # Exit the script after option 5 is selected
        ;;
esac
