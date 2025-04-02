# Fedora Ansible Setup
*Automate setup of your freshly installed workstation OS!* 😎

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

**Global Default Variables**:
- `fedora_version`: `41`
- `hostname`: `"{{ user }}-pc"`
- `bluetooth_name`: `"{{ hostname }}"`
- `tmpdir`: `"/tmp/fedora-setup"`
- `setupDir`: `"/setup"`

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

**Default Variables:**
_None_

### Base
Sets up essential packages, updates the system, and configures the RPM Fusion repository for additional software.

**Tags:**
- `base`
- `rpmfusion`
- `update`

**Default Variables:**
- `fedora_version`: `41`

### Bash
Adds useful Bash aliases and global settings for improved terminal usability.

**Tags:**
- `bash`

**Default Variables:**
- `user_bashrc_include_lines`:  
  ```yml
  - alias getip='curl ipecho.net/plain && echo'
  - alias update-grub-bios='sudo grub2-mkconfig -o /boot/efi/EFI/fedora/grub.cfg'
  - alias update-grub-uefi='sudo grub2-mkconfig -o /boot/grub2/grub.cfg'
  - alias update-grub='update-grub-bios && update-grub-uefi'
  ```
- `root_bashrc_include_lines`: `{{ user_bashrc_include_lines }}`
- `inputrc_include_lines`:  
  ```yml
  - set completion-ignore-case On
  ```

### Browsers
Installs common web browsers, including Firefox, Chromium, and Tor Browser.

**Tags:**
- `browsers`

**Default Variables:**
_None_

### Cryptomator
Downloads and sets up Cryptomator, a tool for encrypting cloud storage files.

**Tags:**
- `cryptomator`

**Default Variables:**
_None_

### Cybersecurity
Installs `interactsh`, a tool for security testing and interaction with external services. This role uses Go to install the tool.

**Tags:**
- `cybersecurity`

**Default Variables:**
_None_

### Development
Installs development tools such as Python, Java, Maven, Visual Studio Code, Go, Node.js (via NVM), and Mono.

**Tags:**
- `development`
- `vscode`
- `go`
- `nvm`
- `mono`

**Default Variables:**
- `user`: _Prompted during execution_

### Discord
Installs the Discord communication platform.

**Tags:**
- `discord`

**Default Variables:**
_None_

### Docker
Sets up Docker, including the repository, installation, and user group configuration.

**Tags:**
- `docker`

**Default Variables:**
- `user`: _Prompted during execution_

### Download Tools
Installs tools for downloading content, such as qBittorrent and youtube-dl.

**Tags:**
- `download`
- `tools`

**Default Variables:**
_None_

### Games
Installs Steam, a popular gaming platform.

**Tags:**
- `games`

**Default Variables:**
_None_

### Git
Configures Git with system-wide and user-specific settings, including name and email.

**Tags:**
- `git`

**Default Variables:**
- `git_system_user`: `"Example user"`
- `git_system_email`: `"user@example.com"`
- `git_global_user`: `{{ git_system_user }}`
- `git_global_email`: `{{ git_system_email }}`
- `git_global_user_root`: `{{ git_global_user }}`
- `git_global_email_root`: `{{ git_global_email }}`

### GNOME
Installs GNOME tools like GNOME Tweaks and Extensions, and configures custom keybindings.

**Tags:**
- `gnome`
- `gnome-keybindings`

**Default Variables:**
- `mediakeys_path`: `'/org/gnome/settings-daemon/plugins/media-keys'`
- `gnome_dconf_values`:  
  ```yml
  - { key: "/org/gnome/desktop/wm/keybindings/show-desktop", value: "['<Super>d']", state: "present" }
  - { key: "{{ mediakeys_path }}/calculator", value: "['<Super>c']", state: "present" }
  - { key: "{{ mediakeys_path }}/home", value: "['<Super>e']", state: "present" }
  - { key: "{{ mediakeys_path }}/volume-down", value: "['<Control><Super>Down']", state: "present" }
  - { key: "{{ mediakeys_path }}/volume-up", value: "['<Control><Super>Up']", state: "present" }
  ```
- `keybind_path`: `'/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings'`
- `custom_keybindings`:  
  ```yml
  - { name: "terminal", command: "gnome-terminal", binding: "<Control><Alt>t" }
  - { name: "cryptomator", command: "~/Desktop/Cryptomator.App", binding: "<Super>k" }
  - { name: "unityhub", command: "unityhub", binding: "<Super>u" }
  ```

### Grub
Configures GRUB bootloader settings and updates the GRUB configuration. I use Intel IOMMU + ACS override patching for my default grub configuration, so you might want to change this by pointing the default_grub_template variable to another file.

*Small note: If you want to download patched linux kernels for Fedora that support acs, there is a great repo by Natalie [here](https://github.com/some-natalie/fedora-acs-override)*.

**Tags:**
- `grub`

**Default Variables:**
- `default_grub_template`: `"default_grub.j2"`

### Multimedia
Installs multimedia tools like VLC, Audacity, FFmpeg, and Spotify.

**Tags:**
- `multimedia`

**Default Variables:**
_None_

### Networking
Installs networking tools such as `nmap` and `net-tools`.

**Tags:**
- `networking`

**Default Variables:**
_None_

### NVIDIA
Installs NVIDIA drivers, removes Nouveau drivers, and configures the system for NVIDIA GPUs.

**Tags:**
- `nvidia`

**Default Variables:**
_None_

### Sidewinderd
Clones, builds, and installs Sidewinderd, a daemon for managing Microsoft Sidewinder keyboards.

**Tags:**
- `sidewinderd`

**Default Variables:**
- `setupDir`: `'/setup'`
- `user`: _Prompted during execution_

### Storage Tools
Installs storage management tools like GParted and ddrescue.

**Tags:**
- `storage_tools`
- `tools`

**Default Variables:**
_None_

### Syncthing
Sets up Syncthing using Docker Compose for file synchronization. This role creates a directory for Syncthing and generates a `docker-compose.yml` file.

**Tags:**
- `syncthing`

**Default Variables:**
- `syncthing_config_template`: `"docker-compose.yml.j2"`

### Unity
Installs Unity Hub, a tool for managing Unity game engine installations.

**Tags:**
- `unity`

**Default Variables:**
_None_

### Virtualization
Installs virtualization tools like QEMU and Docker for managing virtual machines and containers.

**Tags:**
- `virtualization`
- `docker`

**Default Variables:**
- `user`: _Prompted during execution_