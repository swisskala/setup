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
           # Ensure pipx binaries are in PATH
           pipx ensurepath 2>/dev/null || true
       else
           print_warning "Failed to install rich-cli via pipx, trying pip3..."
           if pip3 install --break-system-packages rich-cli 2>/dev/null; then
               print_success "rich-cli installed successfully via pip3 (system-wide)"
           else
               print_warning "Failed to install rich-cli"
               print_warning "You can install it manually later with: pipx install rich-cli"
           fi
       fi
       
       # Install Mission Center via Flatpak for Debian systems
       print_status "Installing Mission Center via Flatpak..."
       if ! command -v flatpak &> /dev/null; then
           print_status "Installing Flatpak first..."
           sudo apt install -y flatpak
       fi
       
       # Add Flathub repository with error handling
       print_status "Adding Flathub repository..."
       FLATPAK_SUCCESS=false
       
       # Try system-wide installation if running as root
       if [[ $EUID -eq 0 ]]; then
           if flatpak remote-add --system --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo 2>/dev/null; then
               print_success "Flathub repository added successfully (system-wide)"
               FLATPAK_SUCCESS=true
           elif flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo 2>/dev/null; then
               print_success "Flathub repository added successfully (user)"
               FLATPAK_SUCCESS=true
           fi
       else
           if sudo flatpak remote-add --system --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo 2>/dev/null; then
               print_success "Flathub repository added successfully (system-wide)"
               FLATPAK_SUCCESS=true
           elif sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo 2>/dev/null; then
               print_success "Flathub repository added successfully (user)"
               FLATPAK_SUCCESS=true
           fi
       fi
       
       if [[ "$FLATPAK_SUCCESS" == false ]]; then
           print_warning "Failed to add Flathub repository"
           print_warning "This might be due to network issues or Flatpak configuration"
           print_warning "Skipping Mission Center installation via Flatpak"
           print_warning "You can add Flathub manually later with:"
           print_warning "  flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo"
           print_success "Essential software installed successfully (apt + pipx only)"
           return
       fi
       
       # Install Mission Center with error handling
       print_status "Installing Mission Center from Flathub..."
       MISSION_CENTER_SUCCESS=false
       
       if [[ $EUID -eq 0 ]]; then
           if flatpak install --system -y flathub io.missioncenter.MissionCenter 2>/dev/null; then
               print_success "Mission Center installed successfully via Flatpak (system-wide)"
               MISSION_CENTER_SUCCESS=true
           elif flatpak install -y flathub io.missioncenter.MissionCenter 2>/dev/null; then
               print_success "Mission Center installed successfully via Flatpak (user)"
               MISSION_CENTER_SUCCESS=true
           fi
       else
           if sudo flatpak install --system -y flathub io.missioncenter.MissionCenter 2>/dev/null; then
               print_success "Mission Center installed successfully via Flatpak (system-wide)"
               MISSION_CENTER_SUCCESS=true
           elif sudo flatpak install -y flathub io.missioncenter.MissionCenter 2>/dev/null; then
               print_success "Mission Center installed successfully via Flatpak (user)"
               MISSION_CENTER_SUCCESS=true
           fi
       fi
       
       if [[ "$MISSION_CENTER_SUCCESS" == false ]]; then
           print_warning "Failed to install Mission Center via Flatpak"
           print_warning "You can install it manually later with:"
           print_warning "  flatpak install io.missioncenter.MissionCenter"
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
   PATH_ADDED=false
   if [[ "$SYSTEM" == "debian" ]]; then
       # Check if running as root and add appropriate paths
       if [[ $EUID -eq 0 ]]; then
           # Running as root - add root's local bin path
           if [[ ":$PATH:" != *":/root/.local/bin:"* ]]; then
               print_status "Adding /root/.local/bin to PATH..."
               echo 'export PATH="/root/.local/bin:$PATH"' >> /root/.bashrc
               export PATH="/root/.local/bin:$PATH"
               PATH_ADDED=true
           fi
       else
           # Running as regular user
           if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
               print_status "Adding ~/.local/bin to PATH..."
               echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
               export PATH="$HOME/.local/bin:$PATH"
               PATH_ADDED=true
           fi
       fi
   elif [[ "$SYSTEM" == "arch" ]]; then
       if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
           print_status "Adding ~/.local/bin to PATH..."
           echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
           export PATH="$HOME/.local/bin:$PATH"
           PATH_ADDED=true
       fi
   fi
   
   if [[ "$PATH_ADDED" == true ]]; then
       print_success "PATH updated - rich command should now be available"
   fi
}
