#!/bin/bash

# Helper function for Mission Center Flatpak installation on Arch
install_mission_center_flatpak_arch() {
    if ! command -v flatpak &> /dev/null; then
        print_status "Installing Flatpak first..."
        sudo pacman -S --needed --noconfirm flatpak
    fi
    
    print_status "Adding Flathub repository..."
    if sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo 2>/dev/null; then
        print_success "Flathub repository added successfully"
        
        print_status "Installing Mission Center from Flathub..."
        if sudo flatpak install -y flathub io.missioncenter.MissionCenter 2>/dev/null; then
            print_success "Mission Center installed successfully via Flatpak"
        else
            print_warning "Failed to install Mission Center via Flatpak"
            print_warning "You can install it manually later with: flatpak install io.missioncenter.MissionCenter"
        fi
    else
        print_warning "Failed to add Flathub repository (network issue?)"
        print_warning "Skipping Mission Center installation via Flatpak"
        print_warning "You can add Flathub manually later with: flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo"
    fi
}

# Step 3: Install essential software
install_essential_software() {
   print_status "Step 3: Installing essential software (kitty, mc, ncdu, unzip, btop, lsd, tealdeer, nano, i3, picom, polkit, xfce-polkit, maim, xclip, mission-center, unbuffer, rich-cli)..."
   
   if [[ "$SYSTEM" == "debian" ]]; then
       print_status "Installing software via apt..."
       sudo apt install -y kitty mc ncdu unzip btop lsd tealdeer nano i3 picom policykit-1 xfce4-notifyd maim xclip expect pipx
       
       # Install rich-cli via pipx
       print_status "Installing rich-cli via pipx..."
       if pipx install rich-cli 2>/dev/null; then
           print_success "rich-cli installed successfully via pipx"
       else
           print_warning "Failed to install rich-cli via pipx"
           print_warning "You can install it manually later with: pipx install rich-cli"
       fi
       
       # Ensure pipx binaries are in PATH
       print_status "Ensuring pipx binaries are in PATH..."
       pipx ensurepath 2>/dev/null || true
       
       # Install Mission Center via Flatpak for Debian systems
       print_status "Installing Mission Center via Flatpak..."
       if ! command -v flatpak &> /dev/null; then
           print_status "Installing Flatpak first..."
           sudo apt install -y flatpak
       fi
       
       # Add Flathub repository with error handling
       print_status "Adding Flathub repository..."
       if sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo 2>/dev/null; then
           print_success "Flathub repository added successfully"
       else
           print_warning "Failed to add Flathub repository (network issue?)"
           print_warning "Skipping Mission Center installation via Flatpak"
           print_success "Essential software installed successfully (apt only)"
           return
       fi
       
       # Install Mission Center with error handling
       print_status "Installing Mission Center from Flathub..."
       if sudo flatpak install -y flathub io.missioncenter.MissionCenter 2>/dev/null; then
           print_success "Mission Center installed successfully via Flatpak"
       else
           print_warning "Failed to install Mission Center via Flatpak"
           print_warning "You can install it manually later with: flatpak install io.missioncenter.MissionCenter"
       fi
       
       print_success "Essential software installed successfully (apt + pipx + Flatpak)"
       
   elif [[ "$SYSTEM" == "arch" ]]; then
       print_status "Installing software via pacman..."
       sudo pacman -S --needed --noconfirm kitty mc ncdu unzip btop lsd tealdeer nano i3-wm picom polkit maim xclip expect python-pip
       
       # Install rich-cli via AUR
       print_status "Installing rich-cli via AUR..."
       if command -v yay &> /dev/null; then
           if yay -S --needed --noconfirm rich-cli 2>/dev/null; then
               print_success "rich-cli installed successfully via AUR"
           else
               print_warning "Failed to install rich-cli via AUR, trying pip..."
               if pip install --user rich-cli 2>/dev/null; then
                   print_success "rich-cli installed successfully via pip"
               else
                   print_warning "Failed to install rich-cli via pip"
                   print_warning "You can install it manually later with: yay -S rich-cli or pip install rich-cli"
               fi
           fi
       else
           print_warning "yay not available, installing rich-cli via pip..."
           if pip install --user rich-cli 2>/dev/null; then
               print_success "rich-cli installed successfully via pip"
           else
               print_warning "Failed to install rich-cli via pip"
               print_warning "You can install it manually later with: pip install rich-cli"
           fi
       fi
       
       # Install xfce-polkit via AUR
       print_status "Installing xfce-polkit via AUR..."
       if command -v yay &> /dev/null; then
           if yay -S --needed --noconfirm xfce-polkit 2>/dev/null; then
               print_success "xfce-polkit installed successfully via AUR"
           else
               print_warning "Failed to install xfce-polkit via AUR"
           fi
       else
           print_warning "yay not available, skipping xfce-polkit installation"
       fi
       
       # Install Mission Center via AUR
       print_status "Installing Mission Center via AUR..."
       if command -v yay &> /dev/null; then
           if yay -S --needed --noconfirm mission-center 2>/dev/null; then
               print_success "Mission Center installed successfully via AUR"
           else
               print_warning "Failed to install Mission Center via AUR, trying Flatpak..."
               install_mission_center_flatpak_arch
           fi
       else
           print_warning "yay not available, installing Mission Center via Flatpak..."
           install_mission_center_flatpak_arch
       fi
       print_success "Essential software installed successfully (pacman + pip + AUR/Flatpak)"
   fi
   
   # Initialize tealdeer cache
   print_status "Initializing tealdeer cache..."
   if command -v tldr &> /dev/null; then
       tldr --update
       print_success "tealdeer cache initialized"
   else
       print_warning "tealdeer not found in PATH, skipping cache initialization"
   fi
   
   # Add pipx/user bin directories to PATH if not already there
   if [[ "$SYSTEM" == "debian" ]]; then
       if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
           print_status "Adding ~/.local/bin to PATH..."
           echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
           print_success "Added ~/.local/bin to PATH (restart terminal or source ~/.bashrc)"
       fi
   elif [[ "$SYSTEM" == "arch" ]]; then
       if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
           print_status "Adding ~/.local/bin to PATH..."
           echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
           print_success "Added ~/.local/bin to PATH (restart terminal or source ~/.bashrc)"
       fi
   fi
}
