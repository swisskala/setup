#!/bin/bash

# System Setup Script for Debian-based and Arch systems
# Author: User
# Description: Automated setup script for new computer installations

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Detect the system type
detect_system() {
    if command -v apt &> /dev/null; then
        SYSTEM="debian"
        PKG_MANAGER="apt"
        print_status "Detected Debian-based system (using apt)"
    elif command -v pacman &> /dev/null; then
        SYSTEM="arch"
        PKG_MANAGER="pacman"
        print_status "Detected Arch-based system (using pacman)"
    else
        print_error "Unsupported system. This script only supports Debian-based and Arch systems."
        exit 1
    fi
}

# Step 1: Update system packages
update_system() {
    print_status "Step 1: Updating system packages..."
    
    if [[ "$SYSTEM" == "debian" ]]; then
        print_status "Updating package lists..."
        sudo apt update
        print_status "Upgrading packages..."
        sudo apt upgrade -y
        print_success "Debian system updated successfully"
        
    elif [[ "$SYSTEM" == "arch" ]]; then
        print_status "Updating Arch system..."
        sudo pacman -Syu --noconfirm
        print_success "Arch system updated successfully"
    fi
}

# Step 2: Install yay (AUR helper) on Arch systems
install_yay() {
    if [[ "$SYSTEM" == "arch" ]]; then
        print_status "Step 2: Installing yay AUR helper..."
        
        # Check if yay is already installed
        if command -v yay &> /dev/null; then
            print_warning "yay is already installed, skipping..."
            return
        fi
        
        # Install base-devel and git if not present
        print_status "Installing prerequisites (base-devel, git)..."
        sudo pacman -S --needed --noconfirm base-devel git
        
        # Clean up any existing yay directory first
        if [[ -d "/tmp/yay" ]]; then
            print_status "Cleaning up previous yay installation directory..."
            sudo rm -rf /tmp/yay
        fi
        
        # Clone and build yay
        print_status "Cloning yay repository..."
        cd /tmp
        git clone https://aur.archlinux.org/yay.git
        cd yay
        
        print_status "Building and installing yay..."
        makepkg -si --noconfirm
        
        # Clean up
        cd /
        rm -rf /tmp/yay
        
        print_success "yay installed successfully"
    else
        print_status "Step 2: Skipping yay installation (not an Arch system)"
    fi
}

# Step 4: Install UbuntuMono Nerd Font
install_nerd_font() {
    print_status "Step 4: Installing UbuntuMono Nerd Font..."
    
    # Create fonts directory if it doesn't exist
    mkdir -p "$HOME/.local/share/fonts"
    
    # Check if font is already installed
    if fc-list | grep -q "UbuntuMono Nerd Font"; then
        print_warning "UbuntuMono Nerd Font already installed, skipping..."
        return
    fi
    
    if [[ "$SYSTEM" == "debian" ]]; then
        print_status "Installing UbuntuMono Nerd Font via package manager..."
        # Try to install via package first
        if sudo apt install -y fonts-ubuntu-nerd 2>/dev/null; then
            print_success "UbuntuMono Nerd Font installed via package manager"
        else
            print_status "Package not available, downloading font manually..."
            install_nerd_font_manual
        fi
        
    elif [[ "$SYSTEM" == "arch" ]]; then
        print_status "Installing UbuntuMono Nerd Font via AUR..."
        if command -v yay &> /dev/null; then
            if yay -S --needed --noconfirm ttf-ubuntu-nerd 2>/dev/null; then
                print_success "UbuntuMono Nerd Font installed via AUR"
            else
                print_status "AUR package failed, downloading font manually..."
                install_nerd_font_manual
            fi
        else
            print_status "yay not available, downloading font manually..."
            install_nerd_font_manual
        fi
    fi
    
    # Refresh font cache
    print_status "Refreshing font cache..."
    fc-cache -fv
    print_success "Font cache refreshed"
}

# Step 5: Install essential software
install_essential_software() {
    print_status "Step 3: Installing essential software (kitty, mc, ncdu, unzip, btop, lsd, tealdeer, nano, mission-center)..."
    
    if [[ "$SYSTEM" == "debian" ]]; then
        print_status "Installing software via apt..."
        sudo apt install -y kitty mc ncdu unzip btop lsd tealdeer nano
        
        # Install Mission Center via Flatpak for Debian systems
        print_status "Installing Mission Center via Flatpak..."
        if ! command -v flatpak &> /dev/null; then
            print_status "Installing Flatpak first..."
            sudo apt install -y flatpak
        fi
        
        # Add Flathub repository with error handling
        print_status "Adding Flathub repository..."
        if sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo 2>/dev/null; then
            print_success "Flathub repository added successfully"
        else
            print_warning "Failed to add Flathub repository (network issue?)"
            print_warning "Skipping Mission Center installation via Flatpak"
            print_success "Essential software installed successfully (apt only)"
            return
        fi
        
        # Install Mission Center with error handling
        print_status "Installing Mission Center from Flathub..."
        if sudo flatpak install -y flathub io.missioncenter.MissionCenter 2>/dev/null; then
            print_success "Mission Center installed successfully via Flatpak"
        else
            print_warning "Failed to install Mission Center via Flatpak"
            print_warning "You can install it manually later with: flatpak install io.missioncenter.MissionCenter"
        fi
        
        print_success "Essential software installed successfully (apt + Flatpak)"
        
    elif [[ "$SYSTEM" == "arch" ]]; then
        print_status "Installing software via pacman..."
        sudo pacman -S --needed --noconfirm kitty mc ncdu unzip btop lsd tealdeer nano
        
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
        print_success "Essential software installed successfully (pacman + AUR/Flatpak)"
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

# Step 6: Replace .bashrc with version from GitHub repo
replace_bashrc() {
    print_status "Step 6: Replacing .bashrc with version from GitHub repo..."
    
    # Create backup if .bashrc exists
    if [[ -f "$HOME/.bashrc" ]]; then
        local backup_file="$HOME/.bashrc.backup.$(date +%Y%m%d_%H%M%S)"
        cp "$HOME/.bashrc" "$backup_file"
        print_status "Backup created: $backup_file"
    fi
    
    # Force delete the old .bashrc
    rm -f "$HOME/.bashrc"
    
    # Check if bashrc exists in the hardcoded path
    if [[ -f "/tmp/setup_runner/bashrc" ]]; then
        print_status "Copying bashrc from GitHub repo to .bashrc in home directory..."
        cp "/tmp/setup_runner/bashrc" "$HOME/.bashrc"
        print_success ".bashrc replaced with GitHub version"
    else
        print_error "bashrc file not found at /tmp/setup_runner/bashrc"
        return 1
    fi
}

# Step 7: Copy KDE shortcuts configuration
copy_kde_shortcuts() {
    print_status "Step 7: Copying KDE shortcuts configuration..."
    
    # Create .config directory if it doesn't exist
    mkdir -p "$HOME/.config"
    
    # Check if KDE shortcuts file exists in the repo
    if [[ -f "/tmp/setup_runner/kglobalshortcutsrc" ]]; then
        # Create backup if file exists
        if [[ -f "$HOME/.config/kglobalshortcutsrc" ]]; then
            local backup_file="$HOME/.config/kglobalshortcutsrc.backup.$(date +%Y%m%d_%H%M%S)"
            cp "$HOME/.config/kglobalshortcutsrc" "$backup_file"
            print_status "Backup created: $backup_file"
        fi
        
        print_status "Copying KDE shortcuts configuration to .config folder..."
        cp "/tmp/setup_runner/kglobalshortcutsrc" "$HOME/.config/kglobalshortcutsrc"
        print_success "KDE shortcuts configuration copied successfully"
    else
        print_warning "kglobalshortcutsrc file not found in GitHub repo"
        print_warning "Skipping KDE shortcuts configuration"
    fi
}

# Step 8: Copy kitty configuration
copy_kitty_config() {
    print_status "Step 8: Copying kitty configuration..."
    
    # Create .config/kitty directory if it doesn't exist
    mkdir -p "$HOME/.config/kitty"
    
    # Check if kitty config file exists in the repo
    if [[ -f "/tmp/setup_runner/kitty.conf" ]]; then
        # Create backup if file exists
        if [[ -f "$HOME/.config/kitty/kitty.conf" ]]; then
            local backup_file="$HOME/.config/kitty/kitty.conf.backup.$(date +%Y%m%d_%H%M%S)"
            cp "$HOME/.config/kitty/kitty.conf" "$backup_file"
            print_status "Backup created: $backup_file"
        fi
        
        print_status "Copying kitty configuration to .config/kitty folder..."
        cp "/tmp/setup_runner/kitty.conf" "$HOME/.config/kitty/kitty.conf"
        print_success "Kitty configuration copied successfully"
    else
        print_warning "kitty.conf file not found in GitHub repo"
        print_warning "Skipping kitty configuration"
    fi
}

# Step 7: Configure UTF-8 locale
configure_locale() {
    print_status "Step 5: Configuring UTF-8 locale..."
    
    if [[ "$SYSTEM" == "debian" ]]; then
        print_status "Configuring locale for Debian-based system..."
        
        # Install locales package first
        print_status "Installing locales package..."
        sudo apt install -y locales
        
        # Check current available locales
        print_status "Checking available locales..."
        available_locales=$(locale -a 2>/dev/null || true)
        
        # Determine which UTF-8 locale to use (prefer en_US, fallback to en_GB or C.UTF-8)
        target_locale=""
        if echo "$available_locales" | grep -q "en_US.utf8"; then
            target_locale="en_US.UTF-8"
            print_status "en_US.UTF-8 locale already available"
        elif echo "$available_locales" | grep -q "en_GB.utf8"; then
            target_locale="en_GB.UTF-8"
            print_status "Using en_GB.UTF-8 locale (en_US.UTF-8 not available)"
        else
            # Generate en_US.UTF-8 locale
            print_status "Enabling en_US.UTF-8 in /etc/locale.gen..."
            sudo sed -i 's/^# *en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
            
            print_status "Generating en_US.UTF-8 locale..."
            sudo locale-gen en_US.UTF-8
            
            # Verify generation was successful
            if locale -a 2>/dev/null | grep -q "en_US.utf8"; then
                target_locale="en_US.UTF-8"
                print_success "en_US.UTF-8 locale generated successfully"
            else
                print_warning "Failed to generate en_US.UTF-8, falling back to C.UTF-8"
                target_locale="C.UTF-8"
            fi
        fi
        
        # Set the locale with error handling
        if [[ -n "$target_locale" ]]; then
            print_status "Setting system locale to $target_locale..."
            if sudo update-locale LANG="$target_locale" 2>/dev/null; then
                print_success "System locale set to $target_locale"
                # Export for current session
                export LANG="$target_locale"
                export LC_ALL="$target_locale"
            else
                print_warning "Failed to set system locale with update-locale, trying manual method..."
                # Fallback: manually write to /etc/default/locale
                echo "LANG=$target_locale" | sudo tee /etc/default/locale > /dev/null
                export LANG="$target_locale"
                export LC_ALL="$target_locale"
                print_success "Locale configuration written to /etc/default/locale"
            fi
        else
            print_error "No suitable UTF-8 locale found or generated"
            return 1
        fi
        
    elif [[ "$SYSTEM" == "arch" ]]; then
        print_status "Configuring locale for Arch-based system..."
        
        # Check if en_US.UTF-8 is already in locale.gen
        if grep -q "^en_US.UTF-8" /etc/locale.gen; then
            print_warning "en_US.UTF-8 already uncommented in locale.gen, skipping..."
        else
            print_status "Uncommenting en_US.UTF-8 in /etc/locale.gen..."
            sudo sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
        fi
        
        print_status "Generating locales..."
        sudo locale-gen
        
        # Verify locale generation
        if locale -a 2>/dev/null | grep -q "en_US.utf8"; then
            # Set the locale in locale.conf
            print_status "Setting system locale to en_US.UTF-8..."
            echo "LANG=en_US.UTF-8" | sudo tee /etc/locale.conf > /dev/null
            export LANG=en_US.UTF-8
            export LC_ALL=en_US.UTF-8
            print_success "Arch locale configured successfully"
        else
            print_error "Failed to generate en_US.UTF-8 locale on Arch system"
            return 1
        fi
    fi
    
    print_success "UTF-8 locale configured successfully"
    print_status "Active locale: $(locale | grep LANG= || echo 'LANG not set')"
    print_status "Note: You may need to reboot for locale changes to take full effect"
}

# Main execution
main() {
    echo "========================================="
    echo "    System Setup Script Starting"
    echo "========================================="
    

    detect_system
    update_system
    install_yay
    install_essential_software
    install_nerd_font
    replace_bashrc
    copy_kde_shortcuts
    copy_kitty_config
    configure_locale

    print_success "Setup script completed successfully!"
    print_status "Remember to run 'source ~/.bashrc' to apply the new configuration!"
    print_status "KDE shortcuts will be available after logging into KDE."
    print_status "Kitty configuration will be applied when you start kitty."
    print_status "UbuntuMono Nerd Font has been installed."
    print_status "Consider rebooting to ensure all locale changes take effect."
}

# Run the main function
main "$@"

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
