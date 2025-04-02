# Fedora Ansible Setup - Automate setup of your freshly installed workstation OS!

This repository contains an Ansible playbook and roles to automate the setup of a Fedora workstation. It installs and configures essential software, tools, and settings tailored for developers, gamers, and general users. Each role is modular, allowing you to customize the setup based on your needs. I made this repository to automate my own workstation and thus there are some specific roles / functions you probably don't want or you want to change default values for. 

*NOTE: There is variable you can set indicating fedora version, although I have only tested this playbook on Fedora Workstation 41*

## How to use
1. Clone repository
1. Run `setup.sh` to install ansible and setup dependencies
1. Use the command `run.sh [ANSIBLE_PLAYBOOK_ARGS]` to run playbook. `[ANSIBLE_PLAYBOOK_ARGS]` are used to specify extra args for the "ansible-playbook" command. Here you can specify --tags for instance to only run certain roles. 

### Tagging system
Each role has a tag corresponding with their name. Use this to filter which roles / functions you want to run. Some roles are quite specific to my setup, so make sure you only run the roles you actually want :)  
Scroll down to see a list of all roles and their tags. 

### Variables
There is one prompt variable called "user". This is the linux user you want to configure for. If you don't want to manually enter the user every time, use the `-e` flag as shown in the examples. 

Some roles have variables that you can override. Do this by creating a `vars/custom.yml` file and put all variables you want to override here. This file is ignored by git. 

### Examples
Run everything (you have to enter user): 
```bash
./run.sh
```

Run everything with user specified:
```bash
./run.sh -e "user=my_fedora_user"
```

Run only the specified tags: 
```bash
./run.sh -e "user=my_fedora_user" --tags "base,browsers"
```

Run everything except the specified tags:  
```bash
./run.sh -e "user=my_fedora_user" --skip-tags "base,browsers"
```

## Full list of all roles

### 3D Modelling
Installs Blender, a popular 3D modeling and animation software.

**Tags:**
- `3d_modelling`

### Base
Sets up essential packages, updates the system, and configures the RPM Fusion repository for additional software.

**Tags:**
- `base`
- `rpmfusion`
- `update`

### Bash
Adds useful Bash aliases and global settings for improved terminal usability.

**Tags:**
- `bash`

### Browsers
Installs common web browsers, including Firefox, Chromium, and Tor Browser.

**Tags:**
- `browsers`

### Cryptomator
Downloads and sets up Cryptomator, a tool for encrypting cloud storage files.

**Tags:**
- `cryptomator`

### Cybersecurity
Installs `interactsh`, a tool for security testing and interaction with external services.

**Tags:**
- `cybersecurity`

### Development
Installs development tools such as Python, Java, Maven, Visual Studio Code, Go, Node.js (via NVM), and Mono.

**Tags:**
- `development`
- `vscode`
- `go`
- `nvm`
- `mono`

### Discord
Installs the Discord communication platform.

**Tags:**
- `discord`

### Docker
Sets up Docker, including the repository, installation, and user group configuration.

**Tags:**
- `docker`

### Download Tools
Installs tools for downloading content, such as qBittorrent and youtube-dl.

**Tags:**
- `download`
- `tools`

### Games
Installs Steam, a popular gaming platform.

**Tags:**
- `games`

### Git
Configures Git with system-wide and user-specific settings, including name and email.

**Tags:**
- `git`

### GNOME
Installs GNOME tools like GNOME Tweaks and Extensions, and configures custom keybindings.

**Tags:**
- `gnome`
- `gnome-keybindings`

### Grub
Configures GRUB bootloader settings and updates the GRUB configuration.

**Tags:**
- `grub`

### Multimedia
Installs multimedia tools like VLC, Audacity, FFmpeg, and Spotify.

**Tags:**
- `multimedia`

### Networking
Installs networking tools such as `nmap` and `net-tools`.

**Tags:**
- `networking`

### NVIDIA
Installs NVIDIA drivers, removes Nouveau drivers, and configures the system for NVIDIA GPUs.

**Tags:**
- `nvidia`

### Sidewinderd
Clones, builds, and installs Sidewinderd, a daemon for managing Microsoft Sidewinder keyboards.

**Tags:**
- `sidewinderd`

### Storage Tools
Installs storage management tools like GParted and ddrescue.

**Tags:**
- `storage_tools`
- `tools`

### Syncthing
Sets up Syncthing using Docker Compose for file synchronization.

**Tags:**
- `syncthing`

### Unity
Installs Unity Hub, a tool for managing Unity game engine installations.

**Tags:**
- `unity`

### Virtualization
Installs virtualization tools like QEMU and Docker for managing virtual machines and containers.

**Tags:**
- `virtualization`
- `docker`