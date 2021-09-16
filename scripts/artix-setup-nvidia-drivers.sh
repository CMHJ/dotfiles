#!/bin/sh

# Exit if there is an error
set -e

if [ "$USER" = "root" ] ; then
    echo "Please don't run this as root"
    exit 1
fi

# Install the driver
sudo pacman -Syyu nvidia nvidia-utils nvidia-settings xorg-server-devel opencl-nvidia

# Setup pacman hook
sudo mkdir -p /etc/pacman.d/hooks/
sudo tee /etc/pacman.d/hooks/nvidia.hook << 'EOF' > /dev/null
[Trigger]
Operation=Install
Operation=Upgrade
Operation=Remove
Type=Package
Target=nvidia
Target=linux
# Change the linux part above and in the Exec line if a different kernel is used

[Action]
Description=Update Nvidia module in initcpio
Depends=mkinitcpio
When=PostTransaction
NeedsTargets
Exec=/bin/sh -c 'while read -r trg; do case $trg in linux) exit 0; esac; done; /usr/bin/mkinitcpio -P'
EOF

# Fix screen tearing issue
sudo mkdir -p /etc/modprobe.d/
sudo tee /etc/modprobe.d/nvidia-drm-nomodeset.conf << 'EOF' > /dev/null
options nvidia-drm modeset=1
EOF

# Configure nvidia card only mode
sudo mkdir -p /etc/X11/xorg.conf.d/
sudo tee /etc/X11/xorg.conf.d/10-nvidia-drm-outputclass.conf << 'EOF' > /dev/null
Section "OutputClass"
    Identifier "intel"
    MatchDriver "i915"
    Driver "modesetting"
EndSection

Section "OutputClass"
    Identifier "nvidia"
    MatchDriver "nvidia-drm"
    Driver "nvidia"
    Option "AllowEmptyInitialConfiguration"
    Option "PrimaryGPU" "yes"
    ModulePath "/usr/lib/nvidia/xorg"
    ModulePath "/usr/lib/xorg/modules"
EndSection
EOF

# Configure xinitrc as redundancy as runit fails to load correctly
tee ~/.xinitrc << 'EOF' > /dev/null
xrandr --setprovideroutputsource modesetting NVIDIA-0
xrandr --auto
EOF

# Configure lightdm correctly
sudo tee /etc/lightdm/display_setup.sh << 'EOF' > /dev/null
#!/bin/sh
xrandr --setprovideroutputsource modesetting NVIDIA-0
xrandr --auto
EOF
sudo chmod +x /etc/lightdm/display_setup.sh
sudo sed -i 's|.*display-setup-script=.*|display-setup-script=/etc/lightdm/display_setup.sh|' /etc/lightdm/lightdm.conf

# Update initramfs
sudo /usr/bin/mkinitcpio -P

echo "Done"
echo "Please reboot now to load NVIDIA drivers"

