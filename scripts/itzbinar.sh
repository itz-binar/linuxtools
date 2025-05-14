#!/bin/bash
# ProfessionalTermux Linux Installer
# Complete script to install Arch Linux or Kali NetHunter in Termux without root
# Version 2.0 - May 2025

# ANSI color codes for better visual experience
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Function to display stylish banner
display_banner() {
    clear
    echo -e "${BLUE}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${NC}"
    echo -e "${BLUE}┃                                                                          ┃${NC}"
    echo -e "${BLUE}┃${WHITE}  +=================================================================+
|                                                                   |
|    ██╗████████╗███████╗██████╗ ██╗███╗   ██╗ █████╗ ██████╗     |
|    ██║╚══██╔══╝╚══███╔╝██╔══██╗██║████╗  ██║██╔══██╗██╔══██╗    |
|    ██║   ██║     ███╔╝ ██████╔╝██║██╔██╗ ██║███████║██████╔╝    |
|    ██║   ██║    ███╔╝  ██╔══██╗██║██║╚██╗██║██╔══██║██╔══██╗    |
|    ██║   ██║   ███████╗██████╔╝██║██║ ╚████║██║  ██║██║  ██║    |
|    ╚═╝   ╚═╝   ╚══════╝╚═════╝ ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝╚═╝  ╚═╝    |
|                                                                   |
+=================================================================+ ┃${NC}"
    echo -e "${BLUE}┃${CYAN}                 Professional Installer for Termux                      ${BLUE}┃${NC}"
    echo -e "${BLUE}┃${PURPLE}                    Arch Linux & Kali NetHunter                         ${BLUE}┃${NC}"
    echo -e "${BLUE}┃${GREEN}                      No Root Required                                  ${BLUE}┃${NC}"
    echo -e "${BLUE}┃                                                                          ┃${NC}"
    echo -e "${BLUE}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${NC}"
    echo ""
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to handle errors
error_exit() {
    echo -e "${RED}[!] ERROR: $1${NC}" >&2
    echo -e "${YELLOW}[!] Installation failed. Press Enter to return to menu...${NC}"
    read -r
    display_menu
}

# Function to show loading animation
show_loading() {
    local pid=$!
    local message="$1"
    local delay=0.1
    local spin='⣾⣽⣻⢿⡿⣟⣯⣷'
    
    echo -ne "${message} "
    
    while kill -0 $pid 2>/dev/null; do
        for i in $(seq 0 7); do
            echo -ne "\r${message} ${spin:$i:1}"
            sleep $delay
        done
    done
    echo -ne "\r${message} ${GREEN}✓${NC}"
    echo ""
}

# Function to display selection menu
display_menu() {
    while true; do
        clear
        display_banner
        echo -e "${YELLOW}[!] Select Linux distribution to install:${NC}"
        echo ""
        echo -e "${CYAN}1. ${WHITE}Arch Linux${NC}"
        echo -e "${CYAN}2. ${WHITE}Kali NetHunter${NC}"
        echo -e "${CYAN}3. ${WHITE}Both${NC}"
        echo -e "${CYAN}4. ${WHITE}Exit${NC}"
        echo ""
        echo -ne "${YELLOW}[?] Enter your choice [1-4]:${NC} "
        read -r choice
        
        case $choice in
            1)
                install_arch_linux
                ;;
            2)
                install_kali_nethunter
                ;;
            3)
                install_both
                ;;
            4)
                echo -e "${YELLOW}[!] Exiting...${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}[!] Invalid option. Please try again.${NC}"
                sleep 2
                ;;
        esac
    done
}

# Function to install Arch Linux
install_arch_linux() {
    # Display disclaimer
    echo -e "${YELLOW}[!] DISCLAIMER: This script will install Arch Linux in Termux.${NC}"
    echo -e "${YELLOW}[!] It requires approximately 4GB of free storage.${NC}"
    echo -ne "${YELLOW}[!] Do you wish to continue? (y/n):${NC} "
    read -r continue
    
    if [[ ! "$continue" =~ ^[Yy]$ ]]; then
        echo -e "${RED}[!] Installation aborted${NC}"
        return
    fi
    
    # Begin installation process
    check_requirements
    update_termux
    install_arch
    configure_arch
    create_launchers
    install_additional_software
    display_arch_completion
    
    echo -e "${YELLOW}[!] Press Enter to return to the main menu...${NC}"
    read -r
}

# Function to install Kali NetHunter
install_kali_nethunter() {
    # Display disclaimer
    echo -e "${YELLOW}[!] DISCLAIMER: This script will install Kali NetHunter in Termux.${NC}"
    echo -e "${YELLOW}[!] It requires approximately 2GB of free storage.${NC}"
    echo -ne "${YELLOW}[!] Do you wish to continue? (y/n):${NC} "
    read -r continue
    
    if [[ ! "$continue" =~ ^[Yy]$ ]]; then
        echo -e "${RED}[!] Installation aborted${NC}"
        return
    fi
    
    # Begin installation process
    check_requirements
    update_termux
    install_kali
    configure_kali
    display_kali_completion
    
    echo -e "${YELLOW}[!] Press Enter to return to the main menu...${NC}"
    read -r
}

# Function to install both distributions
install_both() {
    # Display disclaimer
    echo -e "${YELLOW}[!] DISCLAIMER: This script will install both Arch Linux and Kali NetHunter.${NC}"
    echo -e "${YELLOW}[!] It requires approximately 6GB of free storage in total.${NC}"
    echo -ne "${YELLOW}[!] Do you wish to continue? (y/n):${NC} "
    read -r continue
    
    if [[ ! "$continue" =~ ^[Yy]$ ]]; then
        echo -e "${RED}[!] Installation aborted${NC}"
        return
    fi
    
    # Begin installation process
    check_requirements
    update_termux
    
    # Install Arch Linux
    echo -e "\n${CYAN}[*] Installing Arch Linux first...${NC}"
    install_arch
    configure_arch
    create_launchers
    install_additional_software
    
    # Install Kali NetHunter
    echo -e "\n${CYAN}[*] Now installing Kali NetHunter...${NC}"
    install_kali
    configure_kali
    
    echo -e "\n${GREEN}[✓] Both distributions installed successfully!${NC}"
    echo -e "${YELLOW}"
    echo -e "To launch Arch Linux:"
    echo -e "  Command: ./arch"
    echo -e "  Or use: archlinux"
    echo -e ""
    echo -e "To launch Kali NetHunter:"
    echo -e "  Command: ./kali"
    echo -e "  Or use: nethunter"
    echo -e ""
    echo -e "For GUI options:"
    echo -e "  Arch: ./arch-gui"
    echo -e "  Kali: ./kali-gui"
    echo -e "${NC}"
    
    echo -e "${YELLOW}[!] Press Enter to return to the main menu...${NC}"
    read -r
}

# Function to check system requirements
check_requirements() {
    echo -e "\n${CYAN}[*] Checking system requirements...${NC}"
    
    # Check if running in Termux
    if [ ! -d "/data/data/com.termux" ]; then
        error_exit "This script must be run in Termux on Android"
    fi
    
    # Check available storage (need at least 4GB free)
    available_storage=$(df $HOME | awk 'NR==2 {print $4/1024/1024}')
    if (( $(echo "$available_storage < 4" | bc -l) )); then
        error_exit "Insufficient storage space. At least 4GB free space required."
    fi
    
    # Check if proot-distro is installed
    if ! command_exists proot-distro; then
        echo -e "${YELLOW}[!] proot-distro not found. Installing...${NC}"
        pkg install proot-distro -y || error_exit "Failed to install proot-distro"
    fi
    
    echo -e "${GREEN}[✓] System requirements satisfied${NC}"
}

# Function to update and upgrade Termux packages
update_termux() {
    echo -e "\n${CYAN}[*] Updating Termux packages...${NC}"
    (pkg update -y && pkg upgrade -y) & show_loading "Updating packages"
    
    # Install necessary packages
    echo -e "\n${CYAN}[*] Installing required packages...${NC}"
    (pkg install wget curl proot proot-distro tar pulseaudio x11-repo -y) & show_loading "Installing dependencies"
    
    echo -e "${GREEN}[✓] Termux environment prepared${NC}"
}

# Function to install Arch Linux using proot-distro
install_arch() {
    echo -e "\n${CYAN}[*] Installing Arch Linux...${NC}"
    
    # Check if Arch is already installed
    if proot-distro list | grep -q arch; then
        echo -e "${YELLOW}[!] Arch Linux is already installed. Reinstalling...${NC}"
        proot-distro remove arch || error_exit "Failed to remove existing Arch installation"
    fi
    
    # Install Arch Linux
    (proot-distro install arch) & show_loading "Installing Arch Linux"
    
    echo -e "${GREEN}[✓] Arch Linux installed successfully${NC}"
}

# Function to configure Arch Linux
configure_arch() {
    echo -e "\n${CYAN}[*] Configuring Arch Linux...${NC}"
    
    # Create configuration script
    mkdir -p $HOME/arch-setup
    cat > $HOME/arch-setup/configure.sh << 'EOF'
#!/bin/bash

# Update package databases
echo "Updating package databases..."
pacman -Sy --noconfirm archlinux-keyring
pacman -Syu --noconfirm

# Install essential packages
echo "Installing essential packages..."
pacman -S --noconfirm base-devel git wget curl sudo nano vim zsh

# Configure locale
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

# Set up timezone
ln -sf /usr/share/zoneinfo/UTC /etc/localtime
hwclock --systohc

# Configure pacman
sed -i 's/#Color/Color/' /etc/pacman.conf
sed -i 's/#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf

# Create user
useradd -m -G wheel -s /bin/bash archuser
echo "archuser:archlinux" | chpasswd
echo "archuser ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/archuser
chmod 440 /etc/sudoers.d/archuser

# Install yay (AUR helper)
cd /tmp
git clone https://aur.archlinux.org/yay-bin.git
cd yay-bin
sudo -u archuser makepkg -si --noconfirm

# Install additional tools
pacman -S --noconfirm neofetch htop tmux python python-pip nodejs npm

# Configure zsh with Oh My Zsh for the user
su - archuser -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# Set up .bashrc and .zshrc with better defaults
cat > /home/archuser/.bashrc << 'END'
# ~/.bashrc
alias ls='ls --color=auto'
alias ll='ls -la'
alias grep='grep --color=auto'
alias ip='ip -color=auto'
PS1='\[\033[01;32m\][\u@\h\[\033[01;37m\] \W\[\033[01;32m\]]\$\[\033[00m\] '
neofetch
END

# Create welcome message
cat > /etc/motd << 'END'
╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║   ╔═╗╦═╗╔═╗╦ ╦  ╦  ╦╔╗╔╦ ╦═╗ ╦                               ║
║   ╠═╣╠╦╝║  ╠═╣  ║  ║║║║║ ║╔╩╦╝                               ║
║   ╩ ╩╩╚═╚═╝╩ ╩  ╩═╝╩╝╚╝╚═╝╩ ╚═                               ║
║                                                               ║
║   Professional Arch Linux Environment for Termux              ║
║                                                               ║
║   - Username: archuser                                        ║
║   - Password: archlinux                                       ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
END

echo "Configuration completed successfully!"
EOF
    
    # Make the configuration script executable
    chmod +x $HOME/arch-setup/configure.sh
    
    # Run the configuration script inside Arch Linux
    echo -e "${YELLOW}[!] This may take some time. Please be patient...${NC}"
    (proot-distro login arch -- bash /data/data/com.termux/files/home/arch-setup/configure.sh) & show_loading "Configuring Arch Linux"
    
    echo -e "${GREEN}[✓] Arch Linux configured successfully${NC}"
}

# Function to create launcher scripts
create_launchers() {
    echo -e "\n${CYAN}[*] Creating launcher scripts...${NC}"
    
    # Create Arch Linux launcher
    cat > $HOME/arch << 'EOF'
#!/bin/bash
clear
# ANSI color codes
BLUE='\033[0;34m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
WHITE='\033[1;37m'
NC='\033[0m'

echo -e "${BLUE}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${NC}"
echo -e "${BLUE}┃${CYAN}                  Launching Arch Linux Environment                   ${BLUE}┃${NC}"
echo -e "${BLUE}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${NC}"
echo ""

# Launch Arch Linux with proper configuration
proot-distro login arch -- su - archuser
EOF
    chmod +x $HOME/arch
    
    # Create GUI launcher (for X11/VNC)
    cat > $HOME/arch-gui << 'EOF'
#!/bin/bash
# Check if X11 packages are installed
if ! command -v Xvnc &> /dev/null; then
    echo "Installing X11 requirements..."
    pkg install x11-repo -y
    pkg install tigervnc -y
fi

# Start VNC server if not running
if ! pgrep -x Xvnc > /dev/null; then
    vncserver -localhost -geometry 1280x720 -depth 24 :1
    echo "VNC Server started on port 5901"
    echo "Connect with a VNC client to localhost:5901"
fi

# Start Arch Linux with X11 forwarding
DISPLAY=:1 proot-distro login arch -- su - archuser -c "export DISPLAY=:1 && startxfce4"
EOF
    chmod +x $HOME/arch-gui
    
    # Create Termux shortcut
    mkdir -p $HOME/.termux/boot
    cat > $HOME/.termux/boot/arch-shortcut << 'EOF'
#!/data/data/com.termux/files/usr/bin/sh
termux-wake-lock
am start -n com.termux/com.termux.app.TermuxActivity
exit
EOF
    chmod +x $HOME/.termux/boot/arch-shortcut
    
    # Add shortcuts to .bashrc
    echo -e "\n# Arch Linux shortcuts" >> $HOME/.bashrc
    echo "alias archlinux='$HOME/arch'" >> $HOME/.bashrc
    echo "alias arch-gui='$HOME/arch-gui'" >> $HOME/.bashrc
    
    echo -e "${GREEN}[✓] Launcher scripts created${NC}"
}

# Function to install additional software in Arch
install_additional_software() {
    echo -e "\n${CYAN}[*] Installing additional software in Arch Linux...${NC}"
    
    # Create software installation script
    cat > $HOME/arch-setup/install-software.sh << 'EOF'
#!/bin/bash

# Install GUI components
echo "Installing XFCE desktop environment..."
pacman -S --noconfirm xorg xfce4 xfce4-goodies lightdm lightdm-gtk-greeter

# Install development tools
echo "Installing development tools..."
pacman -S --noconfirm code firefox chromium

# Install multimedia tools
echo "Installing multimedia tools..."
pacman -S --noconfirm vlc audacious gimp

# Install network tools
echo "Installing network tools..."
pacman -S --noconfirm nmap wireshark-qt

# Enable lightdm service
systemctl enable lightdm

echo "Additional software installation completed!"
EOF
    
    # Make the script executable
    chmod +x $HOME/arch-setup/install-software.sh
    
    # Run the script inside Arch Linux
    (proot-distro login arch -- bash /data/data/com.termux/files/home/arch-setup/install-software.sh) & show_loading "Installing additional software"
    
    echo -e "${GREEN}[✓] Additional software installed${NC}"
}

# Function to display completion message for Arch
display_arch_completion() {
    clear
    echo -e "${BLUE}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${NC}"
    echo -e "${BLUE}┃                                                                          ┃${NC}"
    echo -e "${BLUE}┃${GREEN}                  Arch Linux Installation Complete!                     ${BLUE}┃${NC}"
    echo -e "${BLUE}┃                                                                          ┃${NC}"
    echo -e "${BLUE}┃${WHITE}  To start Arch Linux Terminal:                                         ${BLUE}┃${NC}"
    echo -e "${BLUE}┃${CYAN}  - Type './arch' or 'archlinux'                                        ${BLUE}┃${NC}"
    echo -e "${BLUE}┃                                                                          ┃${NC}"
    echo -e "${BLUE}┃${WHITE}  To start Arch Linux with GUI:                                         ${BLUE}┃${NC}"
    echo -e "${BLUE}┃${CYAN}  - Type './arch-gui'                                                   ${BLUE}┃${NC}"
    echo -e "${BLUE}┃${CYAN}  - Then connect with a VNC client to localhost:5901                    ${BLUE}┃${NC}"
    echo -e "${BLUE}┃                                                                          ┃${NC}"
    echo -e "${BLUE}┃${WHITE}  Default credentials:                                                  ${BLUE}┃${NC}"
    echo -e "${BLUE}┃${CYAN}  - Username: archuser                                                  ${BLUE}┃${NC}"
    echo -e "${BLUE}┃${CYAN}  - Password: archlinux                                                 ${BLUE}┃${NC}"
    echo -e "${BLUE}┃                                                                          ┃${NC}"
    echo -e "${BLUE}┃${WHITE}  Note: The first boot may take longer as services are initialized.      ${BLUE}┃${NC}"
    echo -e "${BLUE}┃                                                                          ┃${NC}"
    echo -e "${BLUE}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${NC}"
    echo ""
}

# Function to install Kali NetHunter
install_kali() {
    echo -e "\n${CYAN}[*] Installing Kali NetHunter...${NC}"
    
    # Setup storage access for Termux
    echo -e "${YELLOW}[!] Setting up storage access...${NC}"
    termux-setup-storage || error_exit "Failed to set up storage access"
    
    # Install required packages
    echo -e "${YELLOW}[!] Installing required packages...${NC}"
    pkg install wget -y || error_exit "Failed to install wget"
    
    # Download NetHunter installer
    echo -e "${YELLOW}[!] Downloading NetHunter installer...${NC}"
    wget -O install-nethunter-termux https://offs.ec/2MceZWr || error_exit "Failed to download NetHunter installer"
    
    # Make installer executable
    chmod +x install-nethunter-termux || error_exit "Failed to make installer executable"
    
    # Run NetHunter installer
    echo -e "${YELLOW}[!] Running NetHunter installer. This may take some time...${NC}"
    echo -e "${YELLOW}[!] When asked to delete rootfs, enter N${NC}"
    ./install-nethunter-termux || error_exit "NetHunter installation failed"
    
    echo -e "${GREEN}[✓] Kali NetHunter installed successfully${NC}"
}

# Function to configure Kali NetHunter
configure_kali() {
    echo -e "\n${CYAN}[*] Configuring Kali NetHunter...${NC}"
    
    # Set up KeX password
    echo -e "${YELLOW}[!] Setting up NetHunter KeX password...${NC}"
    nethunter kex passwd || error_exit "Failed to set up KeX password"
    
    # Create launcher scripts for Kali
    cat > $HOME/kali << 'EOF'
#!/bin/bash
clear
# ANSI color codes
BLUE='\033[0;34m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
WHITE='\033[1;37m'
NC='\033[0m'

echo -e "${BLUE}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${NC}"
echo -e "${BLUE}┃${CYAN}                 Launching Kali NetHunter Terminal                    ${BLUE}┃${NC}"
echo -e "${BLUE}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${NC}"
echo ""

# Launch Kali NetHunter
nethunter
EOF
    chmod +x $HOME/kali
    
    # Create launcher for Kali GUI
    cat > $HOME/kali-gui << 'EOF'
#!/bin/bash
clear
# ANSI color codes
BLUE='\033[0;34m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
WHITE='\033[1;37m'
YELLOW='\033[0;33m'
NC='\033[0m'

echo -e "${BLUE}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${NC}"
echo -e "${BLUE}┃${CYAN}                   Launching Kali NetHunter KeX                      ${BLUE}┃${NC}"
echo -e "${BLUE}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${NC}"
echo ""

echo -e "${YELLOW}[!] Starting KeX server...${NC}"
nethunter kex &

echo -e "${YELLOW}[!] To use the GUI, install NetHunter KeX client from:${NC}"
echo -e "${GREEN}    https://store.nethunter.com/en/${NC}"
echo ""
echo -e "${YELLOW}[!] To stop the KeX server, use: nethunter kex stop${NC}"
echo -e "${YELLOW}[!] or: nh kex stop${NC}"
echo ""
echo -e "${GREEN}[✓] KeX server started. Connect using the NetHunter KeX client app${NC}"
EOF
    chmod +x $HOME/kali-gui
    
    # Create a document explaining how to get and use KeX client
    cat > $HOME/kali-kex-instructions << 'EOF'
# Installing and Using NetHunter KeX Client

To use the graphical interface of Kali NetHunter, follow these steps:

## 1. Install NetHunter Store App
   - Visit: https://store.nethunter.com/en/
   - Download and install the NetHunter Store APK
   - Allow installation from this source when prompted

## 2. Install NetHunter KeX Client
   - Open the NetHunter Store app
   - Search for "KeX"
   - Download and install the "NetHunter KeX" app
   - Grant necessary permissions when prompted

## 3. Connect to the KeX Server
   - Start the KeX server using the command: ./kali-gui
   - Open the NetHunter KeX Client app
   - Configure as follows:
     * Port: 5901 (or as displayed when starting the server)
     * Username: kali
     * Password: (the password you set during configuration)
   - Press Connect

## 4. Working with KeX
   - The full Kali Linux desktop environment will be displayed
   - All tools can be accessed from the applications menu
   - Terminal provides full access to command-line tools
   - To stop the KeX server, use: nethunter kex stop (or nh kex stop)

## Troubleshooting
   - If connection fails, make sure the KeX server is running
   - Verify you're using the correct password
   - Check if any firewall is blocking the connection
   - Try restarting both server and client
EOF
    
    # Add shortcuts to .bashrc
    echo -e "\n# Kali NetHunter shortcuts" >> $HOME/.bashrc
    echo "alias kali='$HOME/kali'" >> $HOME/.bashrc
    echo "alias kali-gui='$HOME/kali-gui'" >> $HOME/.bashrc
    
    echo -e "${GREEN}[✓] Kali NetHunter configured successfully${NC}"
    echo -e "${YELLOW}[!] Instructions for installing and using KeX client saved to:${NC}"
    echo -e "${CYAN}    $HOME/kali-kex-instructions${NC}"
}

# Function to display completion message for Kali
display_kali_completion() {
    clear
    echo -e "${BLUE}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${NC}"
    echo -e "${BLUE}┃                                                                          ┃${NC}"
    echo -e "${BLUE}┃${GREEN}                 Kali NetHunter Installation Complete!                  ${BLUE}┃${NC}"
    echo -e "${BLUE}┃                                                                          ┃${NC}"
    echo -e "${BLUE}┃${WHITE}  To start Kali NetHunter Terminal:                                      ${BLUE}┃${NC}"
    echo -e "${BLUE}┃${CYAN}  - Type 'kali' or './kali' or 'nethunter' or 'nh'                        ${BLUE}┃${NC}"
    echo -e "${BLUE}┃                                                                          ┃${NC}"
    echo -e "${BLUE}┃${WHITE}  To start Kali NetHunter with GUI:                                      ${BLUE}┃${NC}"
    echo -e "${BLUE}┃${CYAN}  - Type 'kali-gui' or './kali-gui'                                       ${BLUE}┃${NC}"
    echo -e "${BLUE}┃${CYAN}  - Then connect with NetHunter KeX Client app                            ${BLUE}┃${NC}"
    echo -e "${BLUE}┃                                                                          ┃${NC}"
    echo -e "${BLUE}┃${WHITE}  To run Kali NetHunter as root:                                          ${BLUE}┃${NC}"
    echo -e "${BLUE}┃${CYAN}  - Type 'nethunter -r' or 'nh -r'                                         ${BLUE}┃${NC}"
    echo -e "${BLUE}┃                                                                          ┃${NC}"
    echo -e "${BLUE}┃${WHITE}  Instructions for using KeX client are saved to:                         ${BLUE}┃${NC}"
    echo -e "${BLUE}┃${CYAN}  $HOME/kali-kex-instructions                                             ${BLUE}┃${NC}"
    echo -e "${BLUE}┃                                                                          ┃${NC}"
    echo -e "${BLUE}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${NC}"
    echo ""
}

# Main execution
display_banner
display_menu
