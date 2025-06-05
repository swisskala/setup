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
fi#!/bin/bash

# Helper function to ask yes/no questions
ask_yes_no() {
    local question="$1"
    local response
    
    while true; do
        echo -n "$question (Y/n): "
        read response </dev/tty
        case $response in
            [Yy]* | "" ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "Please answer yes (y) or no (n).";;
        esac
    done
}

# Step 5: Replace .bashrc with version from GitHub repo
replace_bashrc() {
    print_status "Step 5: Replacing .bashrc with version from GitHub repo..."
    
    if ! ask_yes_no "Do you want to replace .bashrc with the version from GitHub repo?"; then
        print_status "Skipping .bashrc replacement"
        return 0
    fi
    
    # Create backup if .bashrc exists
    if [[ -f "$HOME/.bashrc" ]]; then
        local backup_file="$HOME/.bashrc.backup.$(date +%Y%m%d_%H%M%S)"
        cp "$HOME/.bashrc" "$backup_file"
        print_status "Backup created: $backup_file"
    fi
    
    # Force delete the old .bashrc
    rm -f "$HOME/.bashrc"
    
    # Check if bashrc exists in the config folder
    if [[ -f "$CONFIG_PATH/bashrc" ]]; then
        print_status "Copying bashrc from GitHub repo to .bashrc in home directory..."
        cp "$CONFIG_PATH/bashrc" "$HOME/.bashrc"
        print_success ".bashrc replaced with GitHub version"
    else#!/bin/bash

# Helper function to ask yes/no questions
ask_yes_no() {
    local question="$1"
    local response
    
    while true; do
        echo -n "$question (Y/n): "
        read response </dev/tty
        case $response in
            [Yy]* | "" ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "Please answer yes (y) or no (n).";;
        esac
    done
}

# Step 5: Replace .bashrc with version from GitHub repo
replace_bashrc() {
    print_status "Step 5: Replacing .bashrc with version from GitHub repo..."
    
    if ! ask_yes_no "Do you want to replace .bashrc with the version from GitHub repo?"; then
        print_status "Skipping .bashrc replacement"
        return 0
    fi
    
    # Create backup if .bashrc exists
    if [[ -f "$HOME/.bashrc" ]]; then
        local backup_file="$HOME/.bashrc.backup.$(date +%Y%m%d_%H%M%S)"
        cp "$HOME/.bashrc" "$backup_file"
        print_status "Backup created: $backup_file"
    fi
    
    # Force delete the old .bashrc
    rm -f "$HOME/.bashrc"
    
    # Check if bashrc exists in the config folder
    if [[ -f "$CONFIG_PATH/bashrc" ]]; then
        print_status "Copying bashrc from GitHub repo to .bashrc in home directory..."
        cp "$CONFIG_PATH/bashrc" "$HOME/.bashrc"
        print_success ".bashrc replaced with GitHub version"
    else
        print_error "bashrc file not found at $CONFIG_PATH/bashrc"
        return 1
    fi
}

# Step 6: Copy KDE shortcuts configuration
copy_kde_shortcuts() {
    print_status "Step 6: Copying KDE shortcuts configuration..."
    
    if ! ask_yes_no "Do you want to copy KDE shortcuts configuration?"; then
        print_status "Skipping KDE shortcuts configuration"
        return 0
    fi
    
    # Create .config directory if it doesn't exist
    mkdir -p "$HOME/.config"
    
    # Check if KDE shortcuts file exists in the config folder
    if [[ -f "$CONFIG_PATH/kglobalshortcutsrc" ]]; then
        # Create backup if file exists
        if [[ -f "$HOME/.config/kglobalshortcutsrc" ]]; then

        print_error "bashrc file not found at $CONFIG_PATH/bashrc"
        return 1
    fi
}

# Step 6: Copy KDE shortcuts configuration
copy_kde_shortcuts() {
    print_status "Step 6: Copying KDE shortcuts configuration..."
    
    if ! ask_yes_no "Do you want to copy KDE shortcuts configuration?"; then
        print_status "Skipping KDE shortcuts configuration"
        return 0
    fi
    
    # Create .config directory if it doesn't exist
    mkdir -p "$HOME/.config"
    
    # Check if KDE shortcuts file exists in the config folder
    if [[ -f "$CONFIG_PATH/kglobalshortcutsrc" ]]; then
        # Create backup if file exists
        if [[ -f "$HOME/.config/kglobalshortcutsrc" ]]; then


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
        
        # Base packages that should be available on all Debian/Ubuntu versions
        local base_packages="kitty mc ncdu unzip btop lsd tealdeer nano i3 picom xfce4-notifyd maim xclip expect pipx"
        
        # Handle polkit packages based on system version
        local polkit_packages=""
        if command -v lsb_release &> /dev/null; then
            local ubuntu_version=$(lsb_release -rs 2>/dev/null)
            local version_major=$(echo "$ubuntu_version" | cut -d. -f1)
            
            # Ubuntu 25+ uses polkitd and pkexec instead of policykit-1
            if [[ "$version_major" -ge 25 ]] 2>/dev/null; then
                print_status "Detected Ubuntu $ubuntu_version - using polkitd and pkexec"
                polkit_packages="polkitd pkexec"
            else
                print_status "Detected Ubuntu $ubuntu_version - using policykit-1"
                polkit_packages="policykit-1"
            fi
        else
            # Fallback: try to detect if policykit-1 is available
            print_status "Could not detect Ubuntu version, checking package availability..."
            if apt-cache show policykit-1 &>/dev/null; then
                print_status "policykit-1 is available - using it"
                polkit_packages="policykit-1"
            else
                print_status "policykit-1 not available - using polkitd and pkexec"
                polkit_packages="polkitd pkexec"
            fi
        fi
        
        # Combine base packages with polkit packages
        local all_packages="$base_packages $polkit_packages"
        
        print_status "Installing packages: $all_packages"
        if sudo apt install -y $all_packages; then
            print_success "Essential software installed successfully (apt)"
        else
            print_error "Failed to install some packages via apt"
            print_status "Trying to install packages individually to identify issues..."
            
            # Try installing packages one by one to identify problematic ones
            for package in $all_packages; do
                print_status "Installing $package..."
                if sudo apt install -y "$package"; then
                    print_success "$package installed successfully"
                else
                    print_warning "Failed to install $package - skipping"
                fi
            done
        fi
        
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

# Step 3: Install Mission Center (Arch only)
install_mission_center() {
    if [[ "$SYSTEM" == "arch" ]]; then
        print_status "Step 3: Installing Mission Center via AUR..."
        if command -v yay &> /dev/null; then
            if yay -S --needed --noconfirm mission-center 2>/dev/null; then
                print_success "Mission Center installed successfully via AUR"
            else
                print_warning "Failed to install Mission Center via AUR"
                print_warning "You can install it manually later with: yay -S mission-center"
            fi
        else
            print_warning "yay not available, skipping Mission Center installation"
            print_warning "Install yay first, then run: yay -S mission-center"
        fi
    else
        print_status "Step 3: Skipping Mission Center installation (Debian system)"
    fi
}

# Step 4: Install rich-cli
install_rich_cli() {
    print_status "Step 4: Installing rich-cli..."
    
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
            print_status "Running: yay -S --needed --noconfirm rich-cli"
            # Remove the error suppression to see what's actually happening
            if yay -S --needed --noconfirm rich-cli; then
                print_success "rich-cli installed successfully via AUR"
                # Verify the installation
                if command -v rich >/dev/null 2>&1; then
                    print_success "rich command is now available"
                else
                    print_warning "rich-cli may have been installed but command not found in PATH"
                    print_status "Checking if rich is installed via pacman..."
                    if pacman -Qi rich-cli >/dev/null 2>&1; then
                        print_status "rich-cli package is installed, you may need to restart your shell"
                    fi
                fi
            else
                print_error "Failed to install rich-cli via AUR"
                print_status "Error details should be visible above"
                print_warning "You can try installing it manually with: yay -S rich-cli"
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
install_mission_center
install_rich_cli

print_success "Installation script completed!"
print_status "You can now test the rich command with: rich --help"
print_status "Note: You may need to restart your shell or reboot for all PATH changes to take effect"
