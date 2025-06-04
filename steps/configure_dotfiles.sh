#!/bin/bash

# Step 5: Replace .bashrc with version from GitHub repo
replace_bashrc() {
    print_status "Step 5: Replacing .bashrc with version from GitHub repo..."
    
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
    
    # Create .config directory if it doesn't exist
    mkdir -p "$HOME/.config"
    
    # Check if KDE shortcuts file exists in the config folder
    if [[ -f "$CONFIG_PATH/kglobalshortcutsrc" ]]; then
        # Create backup if file exists
        if [[ -f "$HOME/.config/kglobalshortcutsrc" ]]; then
            local backup_file="$HOME/.config/kglobalshortcutsrc.backup.$(date +%Y%m%d_%H%M%S)"
            cp "$HOME/.config/kglobalshortcutsrc" "$backup_file"
            print_status "Backup created: $backup_file"
        fi
        
        print_status "Copying KDE shortcuts configuration to .config folder..."
        cp "$CONFIG_PATH/kglobalshortcutsrc" "$HOME/.config/kglobalshortcutsrc"
        print_success "KDE shortcuts configuration copied successfully"
    else
        print_warning "kglobalshortcutsrc file not found in config folder"
        print_warning "Skipping KDE shortcuts configuration"
    fi
}

# Step 7: Copy kitty configuration
copy_kitty_config() {
    print_status "Step 7: Copying kitty configuration..."
    
    # Create .config/kitty directory if it doesn't exist
    mkdir -p "$HOME/.config/kitty"
    
    # Check if kitty config file exists in the config folder
    if [[ -f "$CONFIG_PATH/kitty.conf" ]]; then
        # Create backup if file exists
        if [[ -f "$HOME/.config/kitty/kitty.conf" ]]; then
            local backup_file="$HOME/.config/kitty/kitty.conf.backup.$(date +%Y%m%d_%H%M%S)"
            cp "$HOME/.config/kitty/kitty.conf" "$backup_file"
            print_status "Backup created: $backup_file"
        fi
        
        print_status "Copying kitty configuration to .config/kitty folder..."
        cp "$CONFIG_PATH/kitty.conf" "$HOME/.config/kitty/kitty.conf"
        
        # Get hostname and set font size accordingly
        local hostname=""
        if command -v hostname &> /dev/null; then
            hostname=$(hostname)
        elif [[ -f /etc/hostname ]]; then
            hostname=$(cat /etc/hostname | tr -d '\n')
        elif [[ -n "$HOSTNAME" ]]; then
            hostname="$HOSTNAME"
        else
            hostname=$(uname -n)
        fi
        
        local font_size=14  # default font size
        
        case "$hostname" in
            "surfarch")
                font_size=22
                print_status "Detected surfarch hostname, setting font size to 22"
                ;;
            "thinkarch")
                font_size=16
                print_status "Detected thinkarch hostname, setting font size to 16"
                ;;
            *)
                print_status "Unknown hostname '$hostname', using default font size of 14"
                ;;
        esac
        
        # Update font size in kitty.conf
        if grep -q "^font_size" "$HOME/.config/kitty/kitty.conf"; then
            sed -i "s/^font_size.*/font_size $font_size/" "$HOME/.config/kitty/kitty.conf"
            print_status "Updated existing font_size setting to $font_size"
        elif grep -q "^#.*font_size" "$HOME/.config/kitty/kitty.conf"; then
            sed -i "s/^#.*font_size.*/font_size $font_size/" "$HOME/.config/kitty/kitty.conf"
            print_status "Uncommented and set font_size to $font_size"
        else
            echo "font_size $font_size" >> "$HOME/.config/kitty/kitty.conf"
            print_status "Added new font_size setting: $font_size"
        fi
        
        print_success "Kitty configuration copied and font size set to $font_size for hostname '$hostname'"
    else
        print_warning "kitty.conf file not found in config folder"
        print_warning "Skipping kitty configuration"
    fi
}

# Step 8: Copy i3 configuration
copy_i3_config() {
    print_status "Step 8: Copying i3 configuration..."
    
    # Create .config/i3 directory if it doesn't exist
    mkdir -p "$HOME/.config/i3"
    
    # Check if i3 config file exists in the config folder
    if [[ -f "$CONFIG_PATH/i3/config" ]]; then
        # Create backup if file exists
        if [[ -f "$HOME/.config/i3/config" ]]; then
            local backup_file="$HOME/.config/i3/config.backup.$(date +%Y%m%d_%H%M%S)"
            cp "$HOME/.config/i3/config" "$backup_file"
            print_status "Backup created: $backup_file"
        fi
        
        print_status "Copying i3 configuration to .config/i3 folder..."
        cp "$CONFIG_PATH/i3/config" "$HOME/.config/i3/config"
        print_success "i3 configuration copied successfully"
    else
        print_warning "config file not found in $CONFIG_PATH/i3/config"
        print_warning "Skipping i3 configuration"
    fi
    
    # Copy i3blocks.conf to /etc/
    if [[ -f "$CONFIG_PATH/etc/i3blocks.conf" ]]; then
        if [[ -f "/etc/i3blocks.conf" ]]; then
            local backup_file="/etc/i3blocks.conf.backup.$(date +%Y%m%d_%H%M%S)"
            sudo cp "/etc/i3blocks.conf" "$backup_file"
            print_status "Backup created: $backup_file"
        fi
        
        print_status "Copying i3blocks.conf to /etc/ folder..."
        sudo cp "$CONFIG_PATH/etc/i3blocks.conf" "/etc/i3blocks.conf"
        print_success "i3blocks configuration copied successfully"
    else
        print_warning "i3blocks.conf file not found in $CONFIG_PATH/etc/i3blocks.conf"
        print_warning "Skipping i3blocks configuration"
    fi
    
    # Copy i3status.conf to /etc/
    if [[ -f "$CONFIG_PATH/etc/i3status.conf" ]]; then
        if [[ -f "/etc/i3status.conf" ]]; then
            local backup_file="/etc/i3status.conf.backup.$(date +%Y%m%d_%H%M%S)"
            sudo cp "/etc/i3status.conf" "$backup_file"
            print_status "Backup created: $backup_file"
        fi
        
        print_status "Copying i3status.conf to /etc/ folder..."
        sudo cp "$CONFIG_PATH/etc/i3status.conf" "/etc/i3status.conf"
        print_success "i3status configuration copied successfully"
    else
        print_warning "i3status.conf file not found in $CONFIG_PATH/etc/i3status.conf"
        print_warning "Skipping i3status configuration"
    fi
}

# Step 9: Copy .xinitrc configuration
copy_xinitrc() {
    print_status "Step 9: Copying .xinitrc configuration..."
    
    # Check if xinitrc file exists in the config folder
    if [[ -f "$CONFIG_PATH/xinitrc" ]]; then
        # Create backup if file exists
        if [[ -f "$HOME/.xinitrc" ]]; then
            local backup_file="$HOME/.xinitrc.backup.$(date +%Y%m%d_%H%M%S)"
            cp "$HOME/.xinitrc" "$backup_file"
            print_status "Backup created: $backup_file"
        fi
        
        print_status "Copying xinitrc from config folder to .xinitrc in home directory..."
        cp "$CONFIG_PATH/xinitrc" "$HOME/.xinitrc"
        
        # Make sure the file has proper permissions
        chmod 644 "$HOME/.xinitrc"
        
        print_success ".xinitrc configuration copied successfully"
    else
        print_warning "xinitrc file not found in config folder"
        print_warning "Skipping .xinitrc configuration"
    fi
}

# Step 10: Copy picom configuration
copy_picom_config() {
    print_status "Step 10: Copying picom configuration..."
    
    # Create .config directory if it doesn't exist
    mkdir -p "$HOME/.config"
    
    # Check if picom config file exists in the config folder
    if [[ -f "$CONFIG_PATH/picom.conf" ]]; then
        # Create backup if file exists
        if [[ -f "$HOME/.config/picom.conf" ]]; then
            local backup_file="$HOME/.config/picom.conf.backup.$(date +%Y%m%d_%H%M%S)"
            cp "$HOME/.config/picom.conf" "$backup_file"
            print_status "Backup created: $backup_file"
        fi
        
        print_status "Copying picom configuration to .config folder..."
        cp "$CONFIG_PATH/picom.conf" "$HOME/.config/picom.conf"
        print_success "Picom configuration copied successfully"
    else
        print_warning "picom.conf file not found in config folder"
        print_warning "Skipping picom configuration"
    fi
}

# Step 12: Replace .profile and .bash_profile with versions from GitHub repo
create_profile() {
    print_status "Step 11: Replacing .profile and .bash_profile with versions from GitHub repo..."
    
    # Handle .profile
    if [[ -f "$HOME/.profile" ]]; then
        local backup_file="$HOME/.profile.backup.$(date +%Y%m%d_%H%M%S)"
        cp "$HOME/.profile" "$backup_file"
        print_status "Backup created: $backup_file"
    fi
    
    # Force delete the old .profile
    rm -f "$HOME/.profile"
    
    # Check if profile exists in the config folder
    if [[ -f "$CONFIG_PATH/profile" ]]; then
        print_status "Copying profile from config folder to .profile in home directory..."
        cp "$CONFIG_PATH/profile" "$HOME/.profile"
        
        # Make sure the file has proper permissions
        chmod 644 "$HOME/.profile"
        
        print_success ".profile replaced with GitHub version"
        
        # Source the profile to apply settings for current session
        if grep -q "QT_STYLE_OVERRIDE" "$HOME/.profile"; then
            source "$HOME/.profile"
            print_status "Sourced .profile for current session"
        fi
    else
        print_error "profile file not found at $CONFIG_PATH/profile"
        return 1
    fi
    
    # Handle .bash_profile
    if [[ -f "$HOME/.bash_profile" ]]; then
        local backup_file="$HOME/.bash_profile.backup.$(date +%Y%m%d_%H%M%S)"
        cp "$HOME/.bash_profile" "$backup_file"
        print_status "Backup created: $backup_file"
    fi
    
    # Force delete the old .bash_profile
    rm -f "$HOME/.bash_profile"
    
    # Check if bash_profile exists in the config folder
    if [[ -f "$CONFIG_PATH/bash_profile" ]]; then
        print_status "Copying bash_profile from config folder to .bash_profile in home directory..."
        cp "$CONFIG_PATH/bash_profile" "$HOME/.bash_profile"
        
        # Make sure the file has proper permissions
        chmod 644 "$HOME/.bash_profile"
        
        print_success ".bash_profile replaced with GitHub version"
    else
        print_warning "bash_profile file not found at $CONFIG_PATH/bash_profile"
        print_warning "Skipping .bash_profile configuration"
    fi
    
    print_success "Profile configuration applied successfully"
    print_status "Profile settings will take effect after next login or reboot"
}

# Step 13: Copy llm-remote script to /usr/local/bin
copy_llm_remote() {
    print_status "Step 12: Copying llm-remote script to /usr/local/bin..."
    
    # Detect system type
    local system_type=""
    if command -v apt >/dev/null 2>&1; then
        system_type="debian"
    elif command -v pacman >/dev/null 2>&1; then
        system_type="arch"
    else
        print_error "Unsupported system - only Debian/Ubuntu and Arch Linux are supported"
        return 1
    fi
    
    local llm_remote_file="llm-remote-${system_type}"
    print_status "Detected ${system_type} system, looking for ${llm_remote_file}"
    
    # Check if the system-specific llm-remote script exists in the config folder
    if [[ -f "$CONFIG_PATH/${llm_remote_file}" ]]; then
        # Create backup if file exists
        if [[ -f "/usr/local/bin/llm-remote" ]]; then
            local backup_file="/usr/local/bin/llm-remote.backup.$(date +%Y%m%d_%H%M%S)"
            sudo cp "/usr/local/bin/llm-remote" "$backup_file"
            print_status "Backup created: $backup_file"
        fi
        
        print_status "Copying ${llm_remote_file} script to /usr/local/bin/llm-remote..."
        sudo cp "$CONFIG_PATH/${llm_remote_file}" "/usr/local/bin/llm-remote"
        
        # Make the script executable
        sudo chmod +x "/usr/local/bin/llm-remote"
        
        print_success "llm-remote script (${llm_remote_file}) copied and made executable in /usr/local/bin"
    else
        print_warning "${llm_remote_file} script not found in config folder"
        print_warning "Expected location: $CONFIG_PATH/${llm_remote_file}"
        print_warning "Skipping llm-remote script installation"
        
        # Check if the old single file exists as fallback
        if [[ -f "$CONFIG_PATH/llm-remote" ]]; then
            print_status "Found generic llm-remote file, using as fallback..."
            sudo cp "$CONFIG_PATH/llm-remote" "/usr/local/bin/llm-remote"
            sudo chmod +x "/usr/local/bin/llm-remote"
            print_success "Generic llm-remote script copied as fallback"
        fi
    fi
}
