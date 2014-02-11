#! /bin/bash

# Assigns the center mouse button the same function as the left mouse button.
# I used this command on my Dell M6400 Laptop.
idNum=$(xinput | grep "SynPS/2 Synaptics TouchPad" | awk '{print $6}' | cut -c4-)
xinput --set-button-map $idNum 1 1
