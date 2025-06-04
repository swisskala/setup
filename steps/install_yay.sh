#!/bin/bash

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