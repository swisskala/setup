#!/bin/bash

# Update Bashrc Script
# Author: User
# Description: Script to add tar examples to existing commandman function in .bashrc

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

# Check if .bashrc exists
check_bashrc() {
    local bashrc="$HOME/.bashrc"
    
    if [[ ! -f "$bashrc" ]]; then
        print_error ".bashrc does not exist at $bashrc"
        print_status "Please run the setup script first to create the basic .bashrc structure"
        exit 1
    else
        print_status "Found .bashrc at $bashrc"
    fi
}

# Check if commandman function exists
check_commandman() {
    local bashrc="$HOME/.bashrc"
    
    if ! grep -q "commandman()" "$bashrc"; then
        print_error "commandman function not found in .bashrc"
        print_status "Please run the setup script first to install the commandman function"
        exit 1
    else
        print_success "Found commandman function in .bashrc"
    fi
}

# Add tar examples to existing commandman function
add_tar_to_commandman() {
    local bashrc="$HOME/.bashrc"
    
    print_status "Adding tar examples to existing commandman function..."
    
    # Check if tar examples are already added
    if grep -q "TAR EXAMPLES:" "$bashrc"; then
        print_warning "TAR EXAMPLES section already exists in commandman function"
        read -p "Do you want to replace it? (y/n): " REPLACE
        
        if [[ ! "$REPLACE" =~ ^[Yy]$ ]]; then
            print_status "Keeping existing TAR EXAMPLES section"
            return
        fi
        
        # Remove existing TAR EXAMPLES section
        print_status "Removing existing TAR EXAMPLES section..."
        sed -i '/TAR EXAMPLES:/,/Type .man/d' "$bashrc"
        
        # Re-add the final line
        sed -i '/tldr --update/a\    echo ""\
    echo -e "\\e[1;37mType '\''man <command>'\'' or '\''tldr <command>'\'' for documentation.\\e[0m"' "$bashrc"
    fi
    
    # Create backup
    local backup_file="$HOME/.bashrc.backup.$(date +%Y%m%d_%H%M%S)"
    cp "$bashrc" "$backup_file"
    print_status "Backup created: $backup_file"
    
    # Find the line with "tldr --update" and add tar examples after it
    sed -i '/tldr --update/a\    echo ""\
    echo -e "\\e[1;33mTAR EXAMPLES:\\e[0m"\
    echo -e "  \\e[1;34mtar -xzf archive.tar.gz\\e[0m # Extract .tar.gz file"\
    echo -e "  \\e[1;34mtar -xjf archive.tar.bz2\\e[0m# Extract .tar.bz2 file"\
    echo -e "  \\e[1;34mtar -czf backup.tar.gz dir/\\e[0m# Create .tar.gz archive"\
    echo -e "  \\e[1;34mtar -tf archive.tar\\e[0m     # List contents without extracting"' "$bashrc"
    
    print_success "Tar examples added successfully to commandman function"
}

# Show updated commandman function
show_updated_function() {
    print_status "Updated commandman function preview:"
    echo "=================================="
    
    # Extract and show the commandman function
    sed -n '/commandman() {/,/^}/p' "$HOME/.bashrc"
}

# Apply changes by sourcing .bashrc
apply_changes() {
    print_status "Applying changes by sourcing .bashrc..."
    source "$HOME/.bashrc"
    print_success "Changes applied successfully!"
    print_status "Run 'commandman' to see the updated function with tar examples"
}

# Main execution
main() {
    echo "========================================="
    echo "    Update .bashrc - Add Tar Examples"
    echo "========================================="
    
    check_bashrc
    check_commandman
    
    echo
    print_status "This script will add tar usage examples to your existing commandman function"
    read -p "Do you want to proceed? (y/n): " PROCEED
    
    if [[ ! "$PROCEED" =~ ^[Yy]$ ]]; then
        print_status "Operation cancelled by user"
        exit 0
    fi
    
    add_tar_to_commandman
    
    echo
    print_status "Would you like to see a preview of the updated function?"
    read -p "(y/n): " SHOW_PREVIEW
    
    if [[ "$SHOW_PREVIEW" =~ ^[Yy]$ ]]; then
        echo
        show_updated_function
    fi
    
    echo
    print_status "Would you like to apply the changes now?"
    read -p "(y/n): " APPLY_NOW
    
    if [[ "$APPLY_NOW" =~ ^[Yy]$ ]]; then
        apply_changes
    fi
    
    echo
    print_success "Update completed successfully!"
    print_status "Your commandman function now includes tar usage examples"
    print_status "Run 'commandman' or 'cmds' to see the updated quick reference"
}

# Run the main function
main "$@"