#!/bin/bash

# Helper function for manual Nerd Font installation
install_nerd_font_manual() {
    print_status "Downloading UbuntuMono Nerd Font manually..."
    
    local font_url="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/UbuntuMono.zip"
    local temp_dir="/tmp/nerd-font-install"
    
    # Create temporary directory
    mkdir -p "$temp_dir"
    cd "$temp_dir"
    
    # Download font
    if command -v wget &> /dev/null; then
        wget -q "$font_url" -O UbuntuMono.zip
    elif command -v curl &> /dev/null; then
        curl -sL "$font_url" -o UbuntuMono.zip
    else
        print_error "Neither wget nor curl available for downloading font"
        return 1
    fi
    
    # Extract and install
    if [[ -f "UbuntuMono.zip" ]]; then
        print_status "Extracting font files..."
        unzip -q UbuntuMono.zip
        
        print_status "Installing font files..."
        find . -name "*.ttf" -exec cp {} "$HOME/.local/share/fonts/" \;
        
        print_success "UbuntuMono Nerd Font installed manually"
    else
        print_error "Failed to download font file"
        return 1
    fi
    
    # Clean up
    cd /
    rm -rf "$temp_dir"
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