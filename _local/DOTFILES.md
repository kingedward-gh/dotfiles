## TO DO

### Common

- **shared folder over lan --> ~/Public**  

sudo pacman -S cifs-utils gvfs-smb avahi nss-mdns
sudo systemctl enable --now avahi-daemon

smbclient -L //192.168.1.100 -U grillous-macmini

mkdir -p ~/Public-mac
sudo mount -t cifs //192.168.1.100/Public ~/Public-macos   
-o username=grillous-macmini,uid=$(id -u),gid=$(id -g),file_mode=0644,dir_mode=0755

mkdir -p ~/.smb
cat > ~/.smb/mac-mini << 'EOF'
username=grillous-macmini
password=banana
EOF
chmod 600 ~/.smb/mac-mini

### Arch

- external monitor
- fn keys
- bluetooth (mouse, airpods, speaker): sudo systemctl enable --now bluetooth
- omarchy transcode ascii SVG_FILE TXT_FILE
- omarchy ascii TEXT
- omarchy-send
- alfred substitute? ulauncher, albert, walkter/rofi
√- ~ char: altgr + ì
√- touchpad: libunput
√- webcam: paru -S bcwc-pcie-git facetimehd-firmware


-----


## NOTES

### Saved stuff

[https://github.com/k4m4/terminals-are-sexy](https://github.com/k4m4/terminals-are-sexy)
[https://github.com/radleylewis/zsh](https://github.com/radleylewis/zsh)
[https://github.com/unixorn/awesome-zsh-plugins](https://github.com/unixorn/awesome-zsh-plugins)
[https://github.com/ohmyzsh/ohmyzsh/wiki](https://github.com/ohmyzsh/ohmyzsh/wiki)

https://felixkratz.github.io/SketchyBar/

