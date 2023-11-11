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
