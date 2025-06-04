#!/bin/bash

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