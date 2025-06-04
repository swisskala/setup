#!/bin/bash

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
    
    # Export variables for use in other scripts
    export SYSTEM
    export PKG_MANAGER
}