## ADB Installation script for youtube-dl and mpv on Android (no root required)

### Prerequisites

* Termux
* Termux:Widget (optional for shortcuts)

### Installation

Connect device with ADB. Unlock device, then run:

```
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
