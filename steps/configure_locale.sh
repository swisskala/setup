#!/bin/bash

# Step 11: Configure UTF-8 locale
configure_locale() {
    print_status "Step 13: Configuring UTF-8 locale..."
    
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