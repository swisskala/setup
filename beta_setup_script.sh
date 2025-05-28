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

# Step 3: Install essential software
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
            sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
        fi
        sudo flatpak install -y flathub io.missioncenter.MissionCenter
        print_success "Essential software installed successfully (apt + Flatpak)"
        
    elif [[ "$SYSTEM" == "arch" ]]; then
        print_status "Installing software via pacman..."
        sudo pacman -S --needed --noconfirm kitty mc ncdu unzip btop lsd tealdeer nano
        
        # Install Mission Center via AUR
        print_status "Installing Mission Center via AUR..."
        if command -v yay &> /dev/null; then
            yay -S --needed --noconfirm mission-center
        else
            print_warning "yay not available, installing Mission Center via Flatpak..."
            if ! command -v flatpak &> /dev/null; then
                print_status "Installing Flatpak first..."
                sudo pacman -S --needed --noconfirm flatpak
            fi
            sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
            sudo flatpak install -y flathub io.missioncenter.MissionCenter
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

# Step 4: Remove old .bashrc and create fresh one
remove_old_bashrc() {
    print_status "Step 4: Removing old .bashrc..."
    
    # Create backup if .bashrc exists
    if [[ -f "/home/$USER/.bashrc" ]]; then
        local backup_file="$HOME/.bashrc.backup.$(date +%Y%m%d_%H%M%S)"
        cp "/home/$USER/.bashrc" "$backup_file"
        print_status "Backup created: $backup_file"
    fi
    
    # Force delete the .bashrc file (no error if it doesn't exist)
    print_status "Force deleting .bashrc file..."
    rm -f "/home/$USER/.bashrc"
    print_success ".bashrc removal completed"
}

# Step 5: Create fresh .bashrc with stock configuration
create_fresh_bashrc() {
    print_status "Step 5: Creating fresh .bashrc with stock configuration..."
    
    local bashrc="$HOME/.bashrc"
    
    # Create completely fresh .bashrc with only the stock line
    print_status "Creating fresh .bashrc with stock configuration..."
    cat > "$bashrc" << 'EOF'
# If not running interactively, don't do anything
[[ $- != *i* ]] && return
EOF
    
    print_success "Fresh .bashrc created from scratch with stock configuration"
}

# Step 6: Configure bash aliases and functions
configure_aliases() {
    print_status "Step 6: Configuring bash aliases and functions..."
    
    local bashrc="$HOME/.bashrc"
    local aliases=(
        "alias la='ls -ahl --color=auto'"
        "alias ll='ls -lh --color=auto'"
        "alias ls='ls --color=auto'"
        "alias lsd='lsd -lh'"
        "alias lsda='lsd -alh'"
        "alias startw='startplasma-wayland'"
        "alias stopx='i3-msg exit'"
    )
    
    # Create .bashrc if it doesn't exist (should already exist from Step 5)
    if [[ ! -f "$bashrc" ]]; then
        print_warning ".bashrc should have been created in Step 5, creating now..."
        cat > "$bashrc" << 'EOF'
# If not running interactively, don't do anything
[[ $- != *i* ]] && return
EOF
    fi
    
    print_status "Checking and adding aliases to .bashrc..."
    
    for alias_line in "${aliases[@]}"; do
        # Extract alias name (everything between 'alias ' and '=')
        alias_name=$(echo "$alias_line" | sed "s/alias \([^=]*\)=.*/\1/")
        
        # Check if alias already exists in .bashrc
        if grep -q "^alias $alias_name=" "$bashrc"; then
            print_warning "Alias '$alias_name' already exists in .bashrc, skipping..."
        else
            print_status "Adding alias: $alias_name"
            echo "$alias_line" >> "$bashrc"
        fi
    done
    
    # Add cd function that auto-lists with lsd
    print_status "Adding enhanced cd function..."
    if grep -q "cd() {" "$bashrc"; then
        print_warning "Custom cd function already exists in .bashrc, skipping..."
    else
        print_status "Adding cd function with auto-listing..."
        cat >> "$bashrc" << 'EOF'

# Enhanced cd function - auto-list directory contents with lsd
cd() {
  builtin cd "$@" && lsd -a
}
EOF
        print_success "Enhanced cd function added"
    fi
    
    # Don't add comment section since we're working with a fresh .bashrc
    print_status "Adding custom aliases comment header..."
    echo "" >> "$bashrc"
    echo "# Custom aliases added by setup script" >> "$bashrc"
    
    print_success "Bash aliases and functions configured successfully"
    print_status "Note: Run 'source ~/.bashrc' or restart your terminal to apply changes"
}

# Step 7: Configure UTF-8 locale
configure_locale() {
    print_status "Step 7: Configuring UTF-8 locale..."
    
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

# Step 8: Add commandman alias with mini manpages
add_commandman_alias() {
    print_status "Step 8: Adding commandman alias with mini manpages..."
    
    local bashrc="$HOME/.bashrc"
    
    # Check if commandman alias already exists (shouldn't in fresh .bashrc)
    if grep -q "commandman" "$bashrc"; then
        print_warning "commandman function already exists in fresh .bashrc (unexpected), skipping..."
        return
    fi
    
    print_status "Adding commandman function to .bashrc..."
    
    # Add the commandman function instead of alias
    cat >> "$bashrc" << 'EOF'

# Mini manpages for installed commands - added by setup script
commandman() {
    echo -e "\e[1;36m=== INSTALLED COMMANDS - QUICK REFERENCE ===\e[0m"
    echo ""
    echo -e "\e[1;33mTERMINAL & SYSTEM:\e[0m"
    echo -e "  \e[1;32mkitty\e[0m         - Modern GPU-accelerated terminal emulator"
    echo -e "  \e[1;32mmc\e[0m            - Midnight Commander file manager"
    echo -e "  \e[1;32mbtop\e[0m          - Interactive system monitor (CPU, memory, processes)"
    echo -e "  \e[1;32mmission-center\e[0m - Modern GUI system monitor with detailed resource info"
    echo -e "  \e[1;32mncdu\e[0m          - NCurses disk usage analyzer - find what uses space"
    echo -e "  \e[1;32mtealdeer\e[0m      - Fast tldr client for simplified command help (use: tldr)"
    echo ""
    echo -e "\e[1;33mFILE OPERATIONS:\e[0m"
    echo -e "  \e[1;32munzip\e[0m         - Extract ZIP archives"
    echo -e "  \e[1;32mlsd\e[0m           - Modern ls with colors and icons"
    echo ""
    echo -e "\e[1;33mFILE LISTING ALIASES:\e[0m"
    echo -e "  \e[1;35mla\e[0m            - List all files with details (ls -ahl --color=auto)"
    echo -e "  \e[1;35mll\e[0m            - List files with details (ls -lh --color=auto)"
    echo -e "  \e[1;35mls\e[0m            - List files with colors (ls --color=auto)"
    echo -e "  \e[1;35mlsd\e[0m           - List with lsd in detailed format (lsd -lh)"
    echo -e "  \e[1;35mlsda\e[0m          - List all files with lsd detailed (lsd -alh)"
    echo ""
    echo -e "\e[1;33mDESKTOP ENVIRONMENT:\e[0m"
    echo -e "  \e[1;35mstartw\e[0m        - Start KDE Plasma Wayland session"
    echo -e "  \e[1;35mstopx\e[0m         - Exit i3 window manager"
    echo ""
    echo -e "\e[1;33mUSAGE EXAMPLES:\e[0m"
    echo -e "  \e[1;34mbtop\e[0m                    # Monitor system resources (terminal)"
    echo -e "  \e[1;34mmission-center\e[0m          # Modern GUI system monitor"
    echo -e "  \e[1;34mncdu /home\e[0m              # Analyze disk usage in /home"
    echo -e "  \e[1;34mlsd\e[0m                     # Pretty file listing"
    echo -e "  \e[1;34mkitty &\e[0m                 # Launch new terminal"
    echo -e "  \e[1;34munzip archive.zip\e[0m       # Extract zip file"
    echo -e "  \e[1;34mtldr ls\e[0m                 # Quick help for ls command"
    echo -e "  \e[1;34mtldr --update\e[0m           # Update tldr database"
    echo ""
    echo -e "\e[1;33mTAR EXAMPLES:\e[0m"
    echo -e "  \e[1;34mtar -xzf archive.tar.gz\e[0m # Extract .tar.gz file"
    echo -e "  \e[1;34mtar -xjf archive.tar.bz2\e[0m# Extract .tar.bz2 file"
    echo -e "  \e[1;34mtar -czf backup.tar.gz dir/\e[0m# Create .tar.gz archive"
    echo -e "  \e[1;34mtar -tf archive.tar\e[0m     # List contents without extracting"
    echo ""
    echo -e "\e[1;37mType 'man <command>' or 'tldr <command>' for documentation.\e[0m"
}
EOF
    
    print_success "commandman function added successfully"
    print_status "Usage: Type 'commandman' to see quick reference of installed tools"
}

# Step 9: Configure colorful bash prompt
configure_prompt() {
    print_status "Step 9: Configuring colorful bash prompt..."
    
    local bashrc="$HOME/.bashrc"
    local prompt_line="PS1='\[\e[1;34m\]\u\[\e[0m\]@\[\e[1;31m\]\h\[\e[0m\]:\w\$ '"
    
    # Check if custom PS1 already exists (shouldn't in fresh .bashrc)
    if grep -q "PS1.*\\\\e\[" "$bashrc"; then
        print_warning "Custom colored PS1 already exists in fresh .bashrc (unexpected), skipping..."
        return
    fi
    
    print_status "Adding colorful prompt to .bashrc..."
    
    # Add the colored prompt
    cat >> "$bashrc" << EOF

# Colorful bash prompt - added by setup script
# Format: [blue]username[reset]@[red]hostname[reset]:path$ 
$prompt_line
EOF
    
    print_success "Colorful bash prompt configured successfully"
    print_status "Prompt format: [blue]username@[red]hostname:path$ "
}

# Step 10: Add cmds shortcut alias
add_cmds_shortcut() {
    print_status "Step 10: Adding cmds shortcut alias..."
    
    local bashrc="$HOME/.bashrc"
    
    # Check if cmds alias already exists (shouldn't in fresh .bashrc)
    if grep -q "alias cmds=" "$bashrc"; then
        print_warning "cmds alias already exists in fresh .bashrc (unexpected), skipping..."
        return
    fi
    
    print_status "Adding cmds shortcut alias to .bashrc..."
    
    # Add the cmds alias
    echo "" >> "$bashrc"
    echo "# Shortcut alias for commandman - added by setup script" >> "$bashrc"
    echo "alias cmds='commandman'" >> "$bashrc"
    
    print_success "cmds shortcut alias added successfully"
    print_status "Usage: Type 'cmds' or 'commandman' to see quick reference of installed tools"
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
    remove_old_bashrc
    create_fresh_bashrc
    configure_aliases
    configure_locale
    add_commandman_alias
    configure_prompt
    add_cmds_shortcut

    print_success "Setup script completed successfully!"
    print_status "Remember to run 'source ~/.bashrc' to apply the new aliases and prompt!"
    print_status "Type 'cmds' or 'commandman' for a quick reference of installed tools."
    print_status "Consider rebooting to ensure all locale changes take effect."
}

# Run the main function
main "$@"