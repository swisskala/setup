#!/bin/bash

set -e  # Exit on any error

# Make all scripts executable first
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
chmod +x "$SCRIPT_DIR/utils"/*.sh 2>/dev/null || true
chmod +x "$SCRIPT_DIR/steps"/*.sh 2>/dev/null || true

# Source all the utility and step functions
source "$SCRIPT_DIR/utils/colors.sh"
source "$SCRIPT_DIR/utils/system_detection.sh"
source "$SCRIPT_DIR/steps/update_system.sh"
source "$SCRIPT_DIR/steps/install_yay.sh"
source "$SCRIPT_DIR/steps/install_software.sh"
source "$SCRIPT_DIR/steps/install_fonts.sh"
source "$SCRIPT_DIR/steps/configure_dotfiles.sh"
source "$SCRIPT_DIR/steps/configure_locale.sh"

# Configuration paths (updated for new folder structure)
export REPO_PATH="$SCRIPT_DIR"
export CONFIG_PATH="$REPO_PATH/config"

# Cleanup function
cleanup_temp_files() {
    # Check if we're running from a temporary location
    if [[ "$SCRIPT_DIR" == /tmp/* ]]; then
        print_status "Script is running from temporary location: $SCRIPT_DIR"
        
        # Ask user if they want to clean up
        echo -n "Do you want to remove the temporary setup files? [y/N]: "
        read -r response
        
        case "$response" in
            [yY]|[yY][eE][sS])
                print_status "Cleaning up temporary files..."
                cd /
                if rm -rf "$SCRIPT_DIR" 2>/dev/null; then
                    print_success "Temporary setup files removed: $SCRIPT_DIR"
                else
                    print_warning "Failed to remove temporary files: $SCRIPT_DIR"
                    print_warning "You may need to remove them manually with: sudo rm -rf $SCRIPT_DIR"
                fi
                ;;
            *)
                print_status "Keeping temporary files at: $SCRIPT_DIR"
                print_status "You can remove them manually later with: rm -rf $SCRIPT_DIR"
                ;;
        esac
    else
        print_status "Script running from permanent location: $SCRIPT_DIR"
        print_status "No cleanup needed."
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
    install_essential_software
    install_nerd_font
    replace_bashrc
    copy_kde_shortcuts
    copy_kitty_config
    copy_i3_config
    copy_xinitrc
    copy_picom_config
    configure_locale
    create_profile
    copy_llm_remote

    print_success "Setup script completed successfully!"
    print_status "Remember to run 'source ~/.bashrc' to apply the new configuration!"
    print_status "KDE shortcuts will be available after logging into KDE."
    print_status "Kitty configuration will be applied when you start kitty."
    print_status "i3 configuration will be applied when you start i3."
    print_status "Picom configuration will be applied when you start picom."
    print_status "UbuntuMono Nerd Font has been installed."
    print_status ".xinitrc configuration will be used when starting X session with startx."
    print_status "QT style override will take effect after next login or reboot."
    print_status "Consider rebooting to ensure all locale changes take effect."
    
    # Cleanup temporary files if running from /tmp
    cleanup_temp_files
}

# Run the main function
main "$@"
