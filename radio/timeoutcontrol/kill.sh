#!/bin/bash
# Ubije radije zaradi povečanja IAT. Skripta start_radio_with_tcpdump_check.sh poskrbi da se radiji ponovno štartajo.

MULTICAST=`grep MULTICAST= "/root/radio/$1" | cut -d '"' -f 2` # Poišče multicast radia, glede na ime skripte, ki je dodeljeno v positional parametru.
RADIOPROCESS=`pgrep -f "$MULTICAST"` # Poišče process ID od FFMPEG, ki v komandi uporablja zgoraj najden multicast naslov.
kill -9 "$RADIOPROCESS" # Proces ubije.

