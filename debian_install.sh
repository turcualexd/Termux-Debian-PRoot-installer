#!/bin/bash

# Prevent sleep during the installation process
termux-wake-lock

# Mount Android storage in Termux
yes | termux-setup-storage >/dev/null 2>&1

# Read username and password
read -r -p "Username: " username ; echo
while true; do
	read -r -s -p "Insert password: " password ; echo
	read -r -s -p "Verify password: " password2 ; echo
	if [ "$password" = "$password2" ]; then
		unset password2
		break
	else
		echo -e "\nPassword do not correspond, try again.\n"
	fi
done

# Solve repo issues and update packages
termux-change-repo

# Upgrade all packages in Termux
yes | pkg upgrade

# Install required packages in Termux
yes | pkg install x11-repo
yes | pkg install termux-x11-nightly proot-distro pulseaudio

# Install Debian proot-distro
yes | proot-distro install debian

# Upgrade all packages in Debian
proot-distro login debian --shared-tmp -- apt update && apt upgrade -y

# Install required packages in Debian
proot-distro login debian --shared-tmp -- apt install sudo xfce4 xfce4-goodies dbus-x11 firefox-esr mesa-utils -y

# Remove useless packages in Debian
proot-distro login debian --shared-tmp -- apt remove xterm -y

# Set correct timezone in Debian
(
timezone=$(getprop persist.sys.timezone)
proot-distro login debian --shared-tmp -- ln -sf "/usr/share/zoneinfo/$timezone" /etc/localtime
)

# Add storage group in Debian
proot-distro login debian --shared-tmp -- groupadd storage

# Add standard user in Debian
proot-distro login debian --shared-tmp -- useradd -m -s /bin/bash -G audio,video,storage "$username"

# Set password for user
echo "$username:$password" | proot-distro login debian --shared-tmp -- chpasswd

# Grant user sudo access
proot-distro login debian --shared-tmp -- bash -c \
"echo '$username ALL=(ALL) ALL' > /etc/sudoers.d/90-$username && chmod 0440 /etc/sudoers.d/90-$username"

# Create script to start Debian on Termux-X11
echo "#!/bin/bash

# Open Termux-X11 app
am start com.termux.x11/com.termux.x11.MainActivity >/dev/null 2>&1
sleep 1

# Kill open processes
set +m
pkill -9 -f pulseaudio >/dev/null 2>&1
pkill -9 -f termux.x11 >/dev/null 2>&1
sleep 1

# Activate Pulseaudio server
LD_PRELOAD=/system/lib64/libskcodec.so \
pulseaudio --start --load='module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1' --exit-idle-time=-1

# Open new X11 process on screen :1
termux-x11 :1 >/dev/null &
sleep 1

# Start XCFE4 on Debian and connect to Termux-X11
proot-distro login debian --user '$username' --shared-tmp -- DISPLAY=:1 PULSE_SERVER=127.0.0.1 \
dbus-launch --exit-with-session xfce4-session

# Kill processes
pkill -9 -f pulseaudio >/dev/null 2>&1
pkill -9 -f termux.x11 >/dev/null 2>&1
set -m

echo -e '\nSession terminated'
exit 0
" > ~/.debian_startup
chmod +x .debian_startup

# Create alias in Termux to start Debian on Termux-X11
echo "alias debian='~/.debian_startup'" >> ~/.bashrc
. ~/.bashrc

# Delete username and password variables
unset username password

# Delete and terminate this script
rm "$BASH_SOURCE"
echo -e "\nInstallation successful!"
termux-wake-unlock