# Debian on Termux with X11

This repository provides a **bash script** to install and configure a Debian distribution inside **Termux** using **proot-distro** and **Termux-X11**. The script sets up a graphical **XFCE4** desktop environment, sound via **PulseAudio**, and a non-root user with `sudo` access. It also sets up an **useful alias** to start Debian with XFCE4 on Termux-X11 by simply typing `debian`.

---

## Features

* Prevents Android from sleeping during installation.
* Configures access to shared storage.
* Installs Debian in Termux using `proot-distro`.
* Sets up **XFCE4 desktop environment** and basic utilities.
* Enables audio through **PulseAudio**.
* Creates a standard user with `sudo` rights.
* Provides an alias to easily launch Debian inside Termux-X11.


## Installation

After installing [Termux](https://github.com/termux/termux-app) and [Termux-X11](https://github.com/termux/termux-x11), simply copy and paste the following command into Termux:

```bash
curl -sLO https://raw.githubusercontent.com/turcualexd/Termux-Debian-PRoot-installer/master/debian_install.sh && . debian_install.sh
```

During installation you will be asked to choose a **username** and **password** for the Debian user.


## Usage

After installation, you can start Debian with XFCE4 on Termux-X11 by simply typing:

```bash
debian
```

This alias runs a helper script that:

* Starts the Termux-X11 app.
* Ensures no conflicting processes are running.
* Launches PulseAudio.
* Starts Debian with XFCE4 session using your created user.
* Cleans up processes after exit.


## Files Created

* `~/.debian_startup` → Script that manages starting/stopping Debian with XFCE4.
* `~/.bashrc` → Updated with an alias `debian` pointing to the startup script.


## User & Permissions

* A **non-root user** is created inside Debian with the username you provided.
* The user is added to the groups: `audio`, `video`, and `storage`.
* A sudoers file `/etc/sudoers.d/90-<username>` is created, granting full `sudo` access.


## Notes

* XFCE4 is installed with its core components (`xfce4`, `xfce4-goodies`).
* Firefox ESR is included as a web browser.
* Storage access is mounted via `termux-setup-storage`.


## Uninstallation

To remove Debian and configuration files:

```bash
proot-distro remove debian
rm -f ~/.debian_startup
sed -i '/alias debian=/d' ~/.bashrc
```


## License

This project is distributed under the MIT License. Feel free to modify and share.

