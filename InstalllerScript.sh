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
