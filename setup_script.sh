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

# Main execution
main() {
    echo "========================================="
    echo "    System Setup Script Starting"
    echo "========================================="
    
    detect_system
    update_system
    install_yay
    
    print_success "Setup script completed successfully!"
}

# Run the main function
main "$@"