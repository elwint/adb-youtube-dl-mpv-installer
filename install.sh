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

until [ "$(echo exit | nc -T localhost 8023 | xargs)" ]; do
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
	[ "$DEBUG" != "1" ] && sed='1,/^$ /d;/^> /d'
	OUT=$(echo 'bash -c '\'"$1"\'' || echo "An error occurred (exit code $?)"; logout' |
		nc -T localhost 8023 | sed -u "$sed" | tee /dev/tty | tail -n1)
	if [[ "$OUT" == "An error occurred"* ]]; then
		exit 1
	fi
}

echo "[*] Waiting for storage permissions"
cmd "until [ -r ~/storage/downloads ]; do sleep .1; done"

echo $'\n[*] Installing mpv'
cmd 'apt -y update && apt -y upgrade && apt -y install mpv && mkdir -p ~/.config/mpv &&
	echo loop-playlist > ~/.config/mpv/mpv.conf &&
	printf "a seek -5\ns seek -60\nd seek 5\nw seek 60\nS playlist-shuffle\n" > ~/.config/mpv/input.conf'

echo $'\n[*] Installing youtube-dl'
cmd "apt -y install python && pip --disable-pip-version-check install youtube-dl"

echo $'\n[*] Adding shortcuts'
if ! adb $1 shell pm list packages | grep -q com.termux.widget; then
	echo "Termux:Widget not installed"
	exit
fi
cmd "mkdir -p ~/.shortcuts"
for f in ./shortcuts/*; do
	name="$(basename "$f")"
	contents="$(cat "$f")"
	cmd "cat > ~/.shortcuts/\"$name\" "$'<<"EOF"\n'"$contents"$'\nEOF'
	cmd "chmod +x ~/.shortcuts/\"$name\""
done
