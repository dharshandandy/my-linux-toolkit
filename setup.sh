#!/bin/bash

# This script will enable the linux toolkit as per user needed.

# Initial Setup
# Make directory for storing the binaries
mkdir -p $HOME/.local/bin

# Add the user bin folder to the PATH variable
if [[ ! ":$PATH:" == *":$HOME/.local/bin:"* ]]; then
	export PATH = $HOME/.local/bin:$PATH
fi

# rm: Command Guard Installation
read -rn1 -p "Do you want to install rm command guard? [Y/n] " confirmation
echo
if [[ "$confirmation" =~ ^[Yy] ]]; then
	/usr/bin/cp ./rm $HOME/.local/bin
	if [[ $? -eq 0 ]]; then
		echo "Successfully installed rm command guard"
		unset confirmation
	else
		echo "Sorry! error occured ERROR: $?"
	fi
fi

# autotrash script Installation
read -rn1 -p "Do you want to install autotrash script? [Y/n] " confirmation
echo 
if [[ "$confirmation" =~ ^[Yy] ]]; then
	/usr/bin/cp ./auto_trash_clean.sh $HOME/.local/bin
	# Get time to execute script daily
	read -r -p "Enter Minute; eg: 0-59" minute_
	read -r -p "Enter Hour in 24-hour format; eg: 0-23" hour_
	CRON_JOB = "$minute_ $hour_ * * * $HOME/.local/bin/auto_trash_clean.sh >> $HOME/.local/bin/auto_trash_clean_cronerror.log 2>&1"

	# Check if already exists
	crontab -l 2>/dev/null | grep -F "$CRON_JOB" >/dev/null

	if [ $? -eq 0 ]; then
	    echo "Cron job already exists"
	else
	    (crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -
	    echo "Cron job added"
	fi

	if [ $? -eq 0 ]; then
		echo "Successfully installed autotrash script"
		unset confirmation
	else
		echo "Sorry! error occured ERROR: $?"
	fi
fi

# git: Command Guard Installation
read -rn1 -p "Do you want to install git command guard? [Y/n] " confirmation
echo
if [[ "$confirmation" =~ ^[Yy] ]]; then
	/usr/bin/cp ./git $HOME/.local/bin
	if [[ $? -eq 0 ]]; then
		echo "Successfully installed rm command guard"
		unset confirmation
	else
		echo "Sorry! error occured ERROR: $?"
	fi
fi


# Customized Keys
read -rn1 -p "Do you want to install customization for Up+PgUp keyboard? [Y/n] " confirmation
echo
if [[ "$confirmation" =~ ^[Yy] ]]; then
	git clone https://github.com/rvaiya/keyd.git
	cd keyd || exit
	make && sudo make install

	sudo tee /etc/keyd/default.conf > /dev/null <<EOF
[ids]
*

[main]
f23 = layer(nav)

[nav]
left = C-S-pageup
right = C-S-pagedown
up = C-S-pageup
down = C-S-pagedown
EOF

	sudo systemctl enable keyd
	sudo systemctl restart keyd

	echo "Keyd customization installed successfully."
fi
