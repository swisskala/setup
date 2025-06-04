#!/bin/bash

# Color output functions
print_status() { echo -e "\e[34m[INFO]\e[0m $1"; }
print_success() { echo -e "\e[32m[SUCCESS]\e[0m $1"; }
print_warning() { echo -e "\e[33m[WARNING]\e[0m $1"; }
print_error() { echo -e "\e[31m[ERROR]\e[0m $1"; }

# Detect system
print_status "Detecting system type..."
if command -v apt >/dev/null 2>&1; then
    SYSTEM="debian"
    print_success "Detected Debian/Ubuntu system"
elif command -v pacman >/dev/null 2>&1; then
    SYSTEM="arch"
    print_success "Detected Arch Linux system"
else
    print_error "Unsupported system - only Debian/Ubuntu and Arch Linux are supported"
    exit 1
fi

# Helper function for Mission Center Flatpak installation on Arch
install_mission_center_flatpak_arch() {
    if ! command -v flatpak &> /dev/null; then
        print_status "Installing Flatpak first..."
        sudo pacman -S --needed --noconfirm flatpak
    fi
    
    print_status "Adding Flathub repository..."
    if sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo 2>/dev/null; then
        print_success "Flathub repository added successfully"
        
        print_status "Installing Mission Center from Flathub..."
        if sudo flatpak install -y flathub io.missioncenter.MissionCenter 2>/dev/null; then
            print_success "Mission Center installed successfully via Flatpak"
        else
            print_warning "Failed to install Mission Center via Flatpak"
            print_warning "You can install it manually later with: flatpak install io.missioncenter.MissionCenter"
        fi
    else
        print_warning "Failed to add Flathub repository (network issue?)"
        print_warning "Skipping Mission Center installation via Flatpak"
        print_warning "You can add Flathub manually later with: flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo"
    fi
}

# Main installation function
install_essential_software() {
   print_status "Installing essential software (kitty, mc, ncdu, unzip, btop, lsd, tealdeer, nano, i3, picom, polkit, xfce-polkit, maim, xclip, mission-center, unbuffer, rich-cli)..."
   
   if [[ "$SYSTEM" == "debian" ]]; then
       print_status "Installing software via apt..."
       sudo apt update
       sudo apt install -y kitty mc ncdu unzip btop lsd tealdeer nano i3 picom policykit-1 xfce4-notifyd maim xclip expect python3-pip python3-venv git build-essential pipx
       
       # Install rich-cli from source
       print_status "Installing rich-cli from source..."
       RICH_BUILD_DIR="/tmp/rich-cli-build"
       RICH_SOURCE_SUCCESS=false
       
       if rm -rf "$RICH_BUILD_DIR" 2>/dev/null && \
          git clone https://github.com/Textualize/rich-cli.git "$RICH_BUILD_DIR" 2>/dev/null && \
          cd "$RICH_BUILD_DIR"; then
           
           print_status "Building rich-cli..."
           if python3 -m venv venv 2>/dev/null && \
              source venv/bin/activate && \
              pip install --upgrade pip setuptools wheel 2>/dev/null && \
              pip install . 2>/dev/null; then
               
               print_status "Installing rich-cli to /usr/bin..."
               if sudo cp venv/bin/rich /usr/bin/rich 2>/dev/null && \
                  sudo chmod +x /usr/bin/rich; then
                   print_success "rich-cli installed successfully from source to /usr/bin"
                   # Test installation with the actual binary path
                   if /usr/bin/rich --version >/dev/null 2>&1; then
                       print_success "rich command is working correctly"
                       RICH_SOURCE_SUCCESS=true
                   else
                       print_warning "rich installed but may have dependency issues"
                   fi
               else
                   print_warning "Failed to copy rich to /usr/bin"
               fi
           else
               print_warning "Failed to build rich-cli from source"
           fi
           
           # Cleanup
           cd - >/dev/null 2>&1
           rm -rf "$RICH_BUILD_DIR" 2>/dev/null
       else
           print_warning "Failed to clone rich-cli repository"
           print_warning "This might be due to network issues or missing git"
       fi
       
       # Fallback: try pipx only if source build actually failed
       if [[ "$RICH_SOURCE_SUCCESS" == false ]]; then
           print_status "Source build failed, trying pipx as fallback..."
           if pipx install rich-cli 2>/dev/null; then
               print_success "rich-cli installed successfully via pipx (fallback)"
               pipx ensurepath 2>/dev/null || true
           else
               print_warning "Both source build and pipx installation failed"
               print_warning "You can install it manually later with: pipx install rich-cli"
           fi
       fi
       
       # Install Mission Center via Flatpak for Debian systems
       print_status "Installing Mission Center via Flatpak..."
       if ! command -v flatpak &> /dev/null; then
           print_status "Installing Flatpak first..."
           sudo apt install -y flatpak
       fi
       
       # Initialize Flatpak if needed
       print_status "Initializing Flatpak..."
       if [[ $EUID -eq 0 ]]; then
           # Running as root - create system directories
           mkdir -p /var/lib/flatpak
           flatpak --version >/dev/null 2>&1 || true
       else
           # Running as user - create user directories  
           mkdir -p ~/.local/share/flatpak
           flatpak --version >/dev/null 2>&1 || true
       fi
       
       # Add Flathub repository with error handling
       print_status "Adding Flathub repository..."
       FLATPAK_SUCCESS=false
       
       # Try different approaches based on user type
       if [[ $EUID -eq 0 ]]; then
           # Running as root - try system-wide first
           print_status "Attempting system-wide Flathub installation..."
           if flatpak remote-add --system --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo; then
               print_success "Flathub repository added successfully (system-wide)"
               FLATPAK_SUCCESS=true
           else
               print_status "System-wide failed, trying user installation..."
               if flatpak remote-add --user --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo; then
                   print_success "Flathub repository added successfully (user)"
                   FLATPAK_SUCCESS=true
               fi
           fi
       else
           # Running as regular user - try user first, then system with sudo
           print_status "Attempting user Flathub installation..."
           if flatpak remote-add --user --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo; then
               print_success "Flathub repository added successfully (user)"
               FLATPAK_SUCCESS=true
           else
               print_status "User installation failed, trying system-wide with sudo..."
               if sudo flatpak remote-add --system --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo; then
                   print_success "Flathub repository added successfully (system-wide)"
                   FLATPAK_SUCCESS=true
               fi
           fi
       fi
       
       if [[ "$FLATPAK_SUCCESS" == false ]]; then
           print_warning "Failed to add Flathub repository"
           print_warning "This might be due to network issues, Flatpak configuration, or permissions"
           print_warning "Troubleshooting steps:"
           print_warning "  1. Check internet connection: curl -I https://dl.flathub.org"
           print_warning "  2. Try manually: flatpak remote-add --user --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo"
           print_warning "  3. Check Flatpak status: flatpak --version && flatpak remotes"
           print_warning "Skipping Mission Center installation via Flatpak"
           print_success "Essential software installed successfully (apt + source build only)"
           return
       fi
       
       # Install Mission Center with error handling
       print_status "Installing Mission Center from Flathub..."
       MISSION_CENTER_SUCCESS=false
       
       if [[ $EUID -eq 0 ]]; then
           # Try system-wide first, then user
           if flatpak install --system -y flathub io.missioncenter.MissionCenter; then
               print_success "Mission Center installed successfully via Flatpak (system-wide)"
               MISSION_CENTER_SUCCESS=true
           elif flatpak install --user -y flathub io.missioncenter.MissionCenter; then
               print_success "Mission Center installed successfully via Flatpak (user)"
               MISSION_CENTER_SUCCESS=true
           fi
       else
           # Try user first, then system with sudo
           if flatpak install --user -y flathub io.missioncenter.MissionCenter; then
               print_success "Mission Center installed successfully via Flatpak (user)"
               MISSION_CENTER_SUCCESS=true
           elif sudo flatpak install --system -y flathub io.missioncenter.MissionCenter; then
               print_success "Mission Center installed successfully via Flatpak (system-wide)"
               MISSION_CENTER_SUCCESS=true
           fi
       fi
       
       if [[ "$MISSION_CENTER_SUCCESS" == false ]]; then
           print_warning "Failed to install Mission Center via Flatpak"
           print_warning "You can install it manually later with:"
           print_warning "  flatpak install --user io.missioncenter.MissionCenter"
           print_warning "  or: sudo flatpak install --system io.missioncenter.MissionCenter"
       fi
       
       print_success "Essential software installed successfully (apt + source build + Flatpak)"
       
   elif [[ "$SYSTEM" == "arch" ]]; then
       print_status "Installing software via pacman..."
       sudo pacman -Sy --needed --noconfirm kitty mc ncdu unzip btop lsd tealdeer nano i3-wm picom polkit maim xclip expect python-pip
       
       # Install rich-cli via AUR
       print_status "Installing rich-cli via AUR..."
       if command -v yay &> /dev/null; then
           if yay -S --needed --noconfirm rich-cli 2>/dev/null; then
               print_success "rich-cli installed successfully via AUR"
           else
               print_warning "Failed to install rich-cli via AUR, trying pip..."
               if pip install --user rich-cli 2>/dev/null; then
                   print_success "rich-cli installed successfully via pip"
               else
                   print_warning "Failed to install rich-cli via pip"
                   print_warning "You can install it manually later with: yay -S rich-cli or pip install rich-cli"
               fi
           fi
       else
           print_warning "yay not available, installing rich-cli via pip..."
           if pip install --user rich-cli 2>/dev/null; then
               print_success "rich-cli installed successfully via pip"
           else
               print_warning "Failed to install rich-cli via pip"
               print_warning "You can install it manually later with: pip install rich-cli"
           fi
       fi
       
       # Install xfce-polkit via AUR
       print_status "Installing xfce-polkit via AUR..."
       if command -v yay &> /dev/null; then
           if yay -S --needed --noconfirm xfce-polkit 2>/dev/null; then
               print_success "xfce-polkit installed successfully via AUR"
           else
               print_warning "Failed to install xfce-polkit via AUR"
           fi
       else
           print_warning "yay not available, skipping xfce-polkit installation"
       fi
       
       # Install Mission Center via AUR
       print_status "Installing Mission Center via AUR..."
       if command -v yay &> /dev/null; then
           if yay -S --needed --noconfirm mission-center 2>/dev/null; then
               print_success "Mission Center installed successfully via AUR"
           else
               print_warning "Failed to install Mission Center via AUR, trying Flatpak..."
               install_mission_center_flatpak_arch
           fi
       else
           print_warning "yay not available, installing Mission Center via Flatpak..."
           install_mission_center_flatpak_arch
       fi
       print_success "Essential software installed successfully (pacman + pip + AUR/Flatpak)"
   fi
   
   # Initialize tealdeer cache
   print_status "Initializing tealdeer cache..."
   if command -v tldr &> /dev/null; then
       tldr --update
       print_success "tealdeer cache initialized"
   else
       print_warning "tealdeer not found in PATH, skipping cache initialization"
   fi
   
   print_success "Installation complete - rich command should be available system-wide"
}

# Check if running as root (optional warning)
if [[ $EUID -eq 0 ]]; then
    print_warning "Running as root - some installations may behave differently"
fi

# Run the installation
print_status "Starting essential software installation..."
install_essential_software

print_success "Installation script completed!"
print_status "You can now test the rich command with: rich --help"
print_status "Note: llm-remote script installation is handled separately by the dotfiles configuration script"
