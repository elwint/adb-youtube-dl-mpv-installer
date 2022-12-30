## Termux yt-dlp and mpv on Android (no root required)

### Prerequisites

* Termux
	* [`termux-setup-storage`](https://wiki.termux.com/wiki/Termux-setup-storage)
* Termux:Widget (optional for shortcuts)

### Installation

#### Manually (recommended)

Run the following commands in Termux:

```bash
apt -y update && apt -y upgrade && apt -y install mpv git python
pip --disable-pip-version-check install yt-dlp
mkdir -p ~/.config/mpv
git clone https://github.com/elwint/adb-youtube-dl-mpv-installer
cp adb-youtube-dl-mpv-installer/*.conf ~/.config/mpv/
```

For shortcuts:

```bash
mkdir -p ~/.shortcuts
cp adb-youtube-dl-mpv-installer/shortcuts/* ~/.shortcuts/
```

#### Automatically (may not work)

Connect device with ADB. Unlock device, then run:

```bash
./install.sh [serial]
```

#### Optional environment variables

|Variable|Description|
|---|---|
|NO_CONFIG=1|Install without creating mpv config files|
|DEBUG=1|Enables debug mode|

### Default mpv configuration

Playlist loop is enabled. Seek with a s d w, shuffle playlist with shift+s, show playlist with l.

### Shortcuts

![shortcuts](https://drive.google.com/uc?export=view&id=1oRMqSEkmU-oVO-Q-1pbmQ0SQAXrmHT4s)
