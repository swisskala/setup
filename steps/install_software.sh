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

# Step 1: Update system
update_system() {
    print_status "Step 1: Updating system..."
    
    if [[ "$SYSTEM" == "debian" ]]; then
        print_status "Updating apt package lists..."
        sudo apt update
        print_success "System updated successfully"
    elif [[ "$SYSTEM" == "arch" ]]; then
        print_status "Syncing pacman databases..."
        sudo pacman -Sy
        print_success "System updated successfully"
    fi
}

# Step 2: Install essential software
install_essential_software() {
    print_status "Step 2: Installing essential software (kitty, mc, ncdu, unzip, btop, lsd, tealdeer, nano, i3, picom, polkit, maim, xclip, expect, pipx)..."
    
    if [[ "$SYSTEM" == "debian" ]]; then
        print_status "Installing software via apt..."
        sudo apt install -y kitty mc ncdu unzip btop lsd tealdeer nano i3 picom policykit-1 xfce4-notifyd maim xclip expect pipx
        print_success "Essential software installed successfully (apt)"
        
    elif [[ "$SYSTEM" == "arch" ]]; then
        print_status "Installing software via pacman..."
        sudo pacman -S --needed --noconfirm kitty mc ncdu unzip btop lsd tealdeer nano i3-wm picom polkit maim xclip expect
        
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
        
        print_success "Essential software installed successfully (pacman + AUR)"
    fi
    
    # Initialize tealdeer cache
    print_status "Initializing tealdeer cache..."
    if command -v tldr &> /dev/null; then
        tldr --update
        print_success "tealdeer cache initialized"
    else
        print_warning "tealdeer not found in PATH, skipping cache initialization"
    fi
}

# Step 3: Install Flatpak
install_flatpak() {
    print_status "Step 3: Installing Flatpak..."
    
    if [[ "$SYSTEM" == "debian" ]]; then
        if ! command -v flatpak &> /dev/null; then
            print_status "Installing Flatpak via apt..."
            sudo apt install -y flatpak
        else
            print_status "Flatpak already installed"
        fi
        
        # Add Flathub repository with error handling
        print_status "Adding Flathub repository..."
        if sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo 2>/dev/null; then
            print_success "Flathub repository added successfully"
        else
            print_warning "Failed to add Flathub repository (network issue?)"
            print_warning "You can add Flathub manually later with: flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo"
        fi
        
    elif [[ "$SYSTEM" == "arch" ]]; then
        if ! command -v flatpak &> /dev/null; then
            print_status "Installing Flatpak via pacman..."
            sudo pacman -S --needed --noconfirm flatpak
        else
            print_status "Flatpak already installed"
        fi
        
        print_status "Adding Flathub repository..."
        if sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo 2>/dev/null; then
            print_success "Flathub repository added successfully"
        else
            print_warning "Failed to add Flathub repository (network issue?)"
            print_warning "You can add Flathub manually later with: flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo"
        fi
    fi
}

# Step 4: Install Mission Center
install_mission_center() {
    print_status "Step 4: Installing Mission Center..."
    
    if [[ "$SYSTEM" == "debian" ]]; then
        # Install Mission Center via Flatpak for Debian systems
        print_status "Installing Mission Center via Flatpak..."
        if sudo flatpak install -y flathub io.missioncenter.MissionCenter 2>/dev/null; then
            print_success "Mission Center installed successfully via Flatpak"
        else
            print_warning "Failed to install Mission Center via Flatpak"
            print_warning "You can install it manually later with: flatpak install io.missioncenter.MissionCenter"
        fi
        
    elif [[ "$SYSTEM" == "arch" ]]; then
        # Install Mission Center via AUR
        print_status "Installing Mission Center via AUR..."
        if command -v yay &> /dev/null; then
            if yay -S --needed --noconfirm mission-center 2>/dev/null; then
                print_success "Mission Center installed successfully via AUR"
            else
                print_warning "Failed to install Mission Center via AUR, trying Flatpak..."
                # Fallback to Flatpak for Arch
                print_status "Installing Mission Center via Flatpak as fallback..."
                if sudo flatpak install -y flathub io.missioncenter.MissionCenter 2>/dev/null; then
                    print_success "Mission Center installed successfully via Flatpak"
                else
                    print_warning "Failed to install Mission Center via Flatpak"
                    print_warning "You can install it manually later with: flatpak install io.missioncenter.MissionCenter"
                fi
            fi
        else
            print_warning "yay not available, installing Mission Center via Flatpak..."
            # Install via Flatpak when yay is not available
            print_status "Installing Mission Center via Flatpak..."
            if sudo flatpak install -y flathub io.missioncenter.MissionCenter 2>/dev/null; then
                print_success "Mission Center installed successfully via Flatpak"
            else
                print_warning "Failed to install Mission Center via Flatpak"
                print_warning "You can install it manually later with: flatpak install io.missioncenter.MissionCenter"
            fi
        fi
    fi
}

# Step 5: Install rich-cli
install_rich_cli() {
    print_status "Step 5: Installing rich-cli..."
    
    if [[ "$SYSTEM" == "debian" ]]; then
        # Install rich-cli via pipx for system-wide access
        print_status "Installing rich-cli via pipx for system-wide access..."
        
        # Install rich-cli system-wide so all users can access it
        if sudo pipx install --global rich-cli 2>/dev/null; then
            print_success "rich-cli installed successfully system-wide via pipx"
            
            # Ensure the global pipx bin directory is in system PATH
            echo 'export PATH="/opt/pipx_global/bin:$PATH"' | sudo tee /etc/profile.d/pipx-global.sh > /dev/null
            sudo chmod +x /etc/profile.d/pipx-global.sh
            
            # Make it available in current session
            export PATH="/opt/pipx_global/bin:$PATH"
            
            # Test installation
            if command -v rich >/dev/null 2>&1 && rich --version >/dev/null 2>&1; then
                print_success "rich command is working correctly and will be available after reboot"
            else
                print_warning "rich installed but may require a shell restart to be fully accessible"
            fi
        else
            print_warning "Failed to install rich-cli system-wide via pipx"
            print_warning "Trying user installation as fallback..."
            
            # Fallback to user installation
            if pipx install rich-cli 2>/dev/null; then
                print_success "rich-cli installed successfully for current user via pipx"
                pipx ensurepath 2>/dev/null || true
                source ~/.bashrc 2>/dev/null || true
                print_warning "rich-cli installed for current user only - other users will need to install it separately"
            else
                print_warning "Failed to install rich-cli via pipx"
                print_warning "You can install it manually later with: pipx install rich-cli"
            fi
        fi
        
    elif [[ "$SYSTEM" == "arch" ]]; then
        # Install rich-cli via AUR using yay
        print_status "Installing rich-cli via AUR..."
        if command -v yay &> /dev/null; then
            if yay -S --needed --noconfirm rich-cli 2>/dev/null; then
                print_success "rich-cli installed successfully via AUR"
                print_success "rich command will be available system-wide after reboot"
            else
                print_warning "Failed to install rich-cli via AUR"
                print_warning "You can install it manually later with: yay -S rich-cli"
            fi
        else
            print_warning "yay not available, skipping rich-cli installation"
            print_warning "Install yay first, then run: yay -S rich-cli"
        fi
    fi
    
    print_success "rich-cli installation completed"
}

# Check if running as root (optional warning)
if [[ $EUID -eq 0 ]]; then
    print_warning "Running as root - some installations may behave differently"
fi

# Run the installation
print_status "Starting software installation process..."

# Execute installation steps in order
update_system
install_essential_software
install_flatpak
install_mission_center
install_rich_cli

print_success "Installation script completed!"
print_status "You can now test the rich command with: rich --help"
print_status "Note: You may need to restart your shell or reboot for all PATH changes to take effect"
