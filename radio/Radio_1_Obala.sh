#!/bin/bash
# Date: 12.12.2017

#---------------------------------------------------------------------------------------------------------------------------------------#

STREAMURL="http://live-b.radio.si:80/Radio1OB"
MULTICAST="232.50.51.12:5200"
RADIONAME="Radio\ 1\ Obala"

PMT_PID="2000"
PCR_PID="2001"
SERVICE_ID="14420"

#---------------------------------------------------------------------------------------------------------------------------------------#
# FFMPEG komanda.

FFMPEG_PID=`pgrep -f "$MULTICAST"` # Peveri PID, morebitnega obstoječega FFMPEG procesa s tem multicast naslovom.

if [ ! "$FFMPEG_PID" ] # Če FFMPEG procesa s tem multicast naslovom še ni, zaženi FFMPEG sejo.
then
        eval FFREPORT=file=/root/radio/log/$MULTICAST:level=32 \
        /root/bin/ffmpeg \
                -threads 0 \
                -re `# Mora biti. Drugače pošilja preveč UDP paketov in zabije buffer. Vidno kot prevelik IAT na sondi.`  \
                -reconnect 1 \
                -reconnect_at_eof 1 \
                -reconnect_streamed 1 \
                -reconnect_delay_max 4294 \
                -deint 0 \
                -i $STREAMURL \
                -c:a mp2 `# Kodek.` \
                -b:a 192k `# Audio Bitrate` \
                -map_metadata 0 \
                -cbr true \
                -force_key_frames 1 \
                -af aresample=44100 \
                -refs 1 \
                -flags \
                -global_header \
                -muxdelay 0 `# Vpliva na IAT. Enak efekt kot max_delay, le da je muxdelay v sekundah, max_delay pa v mikrosekundah.` \
                -metadata service_provider="Telemach" \
                -metadata service_name=$RADIONAME `# Ime radia vidno v PID` \
                -maxrate 256k \
                -minrate 192k \
                -bufsize 256k `# Mora biti najmanj polovico bitrata. Manjši kot je, večkrat se preverja, da je bitrate pravilen.` \
                -mpegts_service_type digital_radio `# Tip streama v PID viden kot digital radio.` \
                -mpegts_service_id $SERVICE_ID `# ID viden v PIDu. Enak kot zadnji biti multicast naslova.` \
                -mpegts_pmt_start_pid $PMT_PID \
                -mpegts_start_pid $PCR_PID \
                -f mpegts \
                \"udp://$MULTICAST?localaddr=172.20.188.178\&pkt_size=188\" </dev/null > /dev/null 2>&1 &
else
        echo "------------- $MULTICAST address has been in use! --------------"
        exit
fi
