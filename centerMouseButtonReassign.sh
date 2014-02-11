#! /bin/bash
#
# I put this script in my home folder. You can place it where you want.
# Put the following ommand in the alias section of /etc/bash.bashrc
#
# /home/<user name>/centerMouseButtonReassign.sh
# 
# Make sure you run chmod 755 on the script to make it an executable script. 
#
# This will be a system wide change.
# Assigns the center mouse button the same function as the left mouse button.
# I used this command on my Dell M6400 Laptop.
idNum=$(xinput | grep "SynPS/2 Synaptics TouchPad" | awk '{print $6}' | cut -c4-)
xinput --set-button-map $idNum 1 1
exit 0
