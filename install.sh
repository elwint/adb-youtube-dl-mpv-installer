#!/bin/bash
echo "[*] Connecting to device"
if ! timeout 5 adb $1 wait-for-device; then
	echo "Could not connect with ADB" >&2
	exit 1
fi

echo "[*] Launching Termux"
adb $1 shell am start -n com.termux/.app.TermuxActivity > /dev/null &&
sleep 5 &&

echo "[*] Setting up telnet connection" &&
adb $1 shell input text "termux-setup-storage\ \&\&\ busybox\ telnetd\ -Fb\ 127.0.0.1:8023\;\ exit\ 0" &&
adb $1 shell input keyevent 66 &&
adb $1 forward tcp:8023 tcp:8023

until echo exit | nc -T localhost 8023 > /dev/null 2>&1; do
	sleep 0.1 && ((i++))
	if [ $i -ge 100 ]; then
		echo "Could not connect to telnet with netcat (screen locked?)" >&2
		exit 1
	fi
done

quit () {
	echo "killall busybox || logout" | nc -T localhost 8023 > /dev/null
}
trap quit EXIT

cmd () {
	OUT=$(echo 'bash -c "'$1'" || echo "An error occurred (exit code $?)"; logout' |
		nc -T localhost 8023 | sed -u '1,/$ /d' | tee /dev/tty | tail -n1)
	[[ "$OUT" == "An error occurred"* ]] && exit 1
}

echo "[*] Waiting for storage permissions"
cmd "until [ -r ~/storage/downloads ]; do sleep .1; done"

echo $'\n[*] Installing mpv'
cmd "apt -y update && apt -y upgrade && apt -y install mpv && mkdir -p ~/.config/mpv && echo loop-playlist > ~/.config/mpv/mpv.conf"

echo $'\n[*] Installing youtube-dl'
cmd "apt -y install python && pip --disable-pip-version-check install youtube-dl"

echo $'\nDone'
