#!/bin/bash

# Add User Script for Debian-based and Arch systems
# Author: User
# Description: Interactive script to add a new user with home directory and sudo privileges

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

# Check if script is run as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_error "This script must be run as root (use sudo)"
        print_status "Usage: sudo $0"
        exit 1
    fi
}

# Detect the system type
detect_system() {
    if command -v apt &> /dev/null; then
        SYSTEM="debian"
        print_status "Detected Debian-based system"
    elif command -v pacman &> /dev/null; then
        SYSTEM="arch"
        print_status "Detected Arch-based system"
    else
        print_error "Unsupported system. This script only supports Debian-based and Arch systems."
        exit 1
    fi
}

# Get username from user input
get_username() {
    echo
    print_status "User Creation Wizard"
    echo "===================="
    
    while true; do
        read -p "Enter the username for the new user: " USERNAME
        
        # Validate username
        if [[ -z "$USERNAME" ]]; then
            print_error "Username cannot be empty. Please try again."
            continue
        fi
        
        # Check if username contains only valid characters
        if [[ ! "$USERNAME" =~ ^[a-z][-a-z0-9]*$ ]]; then
            print_error "Invalid username. Use only lowercase letters, numbers, and hyphens. Must start with a letter."
            continue
        fi
        
        # Check if user already exists
        if id "$USERNAME" &>/dev/null; then
            print_error "User '$USERNAME' already exists. Please choose a different username."
            continue
        fi
        
        # Confirm username
        echo
        print_status "You entered: $USERNAME"
        read -p "Is this correct? (y/n): " CONFIRM
        
        if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
            break
        fi
    done
}

# Install sudo if not present
install_sudo() {
    if ! command -v sudo &> /dev/null; then
        print_status "Installing sudo..."
        
        if [[ "$SYSTEM" == "debian" ]]; then
            apt update
            apt install -y sudo
        elif [[ "$SYSTEM" == "arch" ]]; then
            pacman -S --needed --noconfirm sudo
        fi
        
        print_success "sudo installed successfully"
    else
        print_status "sudo is already installed"
    fi
}

# Create the user
create_user() {
    print_status "Creating user '$USERNAME'..."
    
    # Create user with home directory
    useradd -m -s /bin/bash "$USERNAME"
    
    if [[ $? -eq 0 ]]; then
        print_success "User '$USERNAME' created successfully"
        print_status "Home directory: /home/$USERNAME"
    else
        print_error "Failed to create user '$USERNAME'"
        exit 1
    fi
}

# Set user password
set_password() {
    print_status "Setting password for user '$USERNAME'..."
    
    while true; do
        passwd "$USERNAME"
        if [[ $? -eq 0 ]]; then
            print_success "Password set successfully for user '$USERNAME'"
            break
        else
            print_error "Failed to set password. Please try again."
        fi
    done
}

# Add user to sudo group
add_to_sudo() {
    print_status "Adding user '$USERNAME' to sudo group..."
    
    if [[ "$SYSTEM" == "debian" ]]; then
        # Add to sudo group on Debian-based systems
        usermod -aG sudo "$USERNAME"
        print_success "User '$USERNAME' added to sudo group"
        
    elif [[ "$SYSTEM" == "arch" ]]; then
        # Add to wheel group on Arch-based systems
        usermod -aG wheel "$USERNAME"
        
        # Ensure wheel group has sudo privileges
        if ! grep -q "^%wheel ALL=(ALL:ALL) ALL" /etc/sudoers; then
            print_status "Enabling sudo for wheel group..."
            echo "%wheel ALL=(ALL:ALL) ALL" >> /etc/sudoers
        fi
        
        print_success "User '$USERNAME' added to wheel group with sudo privileges"
    fi
}

# Display user information
display_user_info() {
    echo
    print_success "User creation completed successfully!"
    echo "=================================="
    print_status "Username: $USERNAME"
    print_status "Home Directory: /home/$USERNAME"
    print_status "Shell: /bin/bash"
    
    if [[ "$SYSTEM" == "debian" ]]; then
        print_status "Groups: $(groups $USERNAME)"
    elif [[ "$SYSTEM" == "arch" ]]; then
        print_status "Groups: $(groups $USERNAME)"
    fi
    
    echo
    print_status "The user '$USERNAME' now has:"
    echo "  ✓ A home directory at /home/$USERNAME"
    echo "  ✓ Bash shell access"
    echo "  ✓ sudo privileges"
    echo
    print_status "You can now switch to this user with: su - $USERNAME"
    print_status "Or login directly as this user on next session"
}

# Main execution
main() {
    echo "========================================="
    echo "         Add User Script"
    echo "========================================="
    
    check_root
    detect_system
    get_username
    install_sudo
    create_user
    set_password
    add_to_sudo
    display_user_info
    
    echo
    print_success "Add user script completed successfully!"
}

# Run the main function
main "$@"