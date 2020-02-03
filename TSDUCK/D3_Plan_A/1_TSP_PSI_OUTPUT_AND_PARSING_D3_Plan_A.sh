#!/bin/bash
# Skripta ustvari dva output fajla.

# 1. $OUTPUT_TSP_PSI_FILE je output, ki ga da TSDUCK s PSI pluginom. Nato ta output fajl grepa za potrebnimi vrednostmi, in jih uredi v pregledno obliko. Ta pregledna oblika se izpiše na zaslonu,
# vendar se ob enem outputa še v tretji output file, ki pa je definiran v skripti 0.

# 2. $OUTPUT_TSP_TSDATE_FILE je output, ki ga da TSDUCK s komando tsdate. Na zaslonu se ne prikaže nič, saj gre vse direktno v ta output file. Vsakič, ko se skripta požene, se ustvari nov fajl.

#--1--#

MPTS=$1 # Spremenljivka MPTS bo nosila vrednost IP MPTSja, ki ga dobi preko pozicijskega parametra od skripte 0.
OUTPUT_TSP_PSI_FILE="/root/outputs/D3_Plan_A/tsp_PSI_output/$MPTS" # Spremenljivka, ki bo imela vrednost kot pot, kjer se bo output file nahajal. Output v fajlu bo od TSDUCK PSI komande.
OUTPUT_TSP_TSDATE_FILE="/root/outputs/D3_Plan_A/tsp_tsdate_output/$MPTS"  # Spremenljivka, ki bo imela vrednost kot pot, kjer se bo output file nahajal. Output v fajlu bo od TSDUCK tsdate komande.

# Izvede se TSP komanda, s pluginom PSI. Output damo v file.
tsp -I ip "$MPTS" --receive-timeout 5000 -P psi --all-versions -P until --seconds 120 -O drop > "$OUTPUT_TSP_PSI_FILE" 

# Poiščemo kakšno TSID vrednost ima ta MPTS in jo damo v spremenljivko $TSID.
TSID=$(grep -A 3 "SDT Actual" "$OUTPUT_TSP_PSI_FILE" | grep "Transport Stream Id" | cut -f "8" -d " ")

echo ""
echo "$MPTS"
echo "-------------------------------------------------------------------------------"
echo "TSID = $TSID"
echo "-------------------------------------------------------------------------------"

# CAT, NIT in BAT PID/VERSION so samo actual. Grepamo njihove vrednosti.
CAT_PID=$(grep "CAT" "$OUTPUT_TSP_PSI_FILE" | cut -f "7" -d " ")
echo "CAT_PID = $CAT_PID"

CAT_TABLE_VERSION=$(grep -A 1 "CAT" "$OUTPUT_TSP_PSI_FILE" | grep "Version" | cut -f "4" -d " " | cut -f "1" -d ",")
echo "CAT_TABLE_VERSION = $CAT_TABLE_VERSION"
echo "-------------------------------------------------------------------------------"

NIT_ACTUAL_PID=$(grep "NIT Actual" "$OUTPUT_TSP_PSI_FILE" | cut -f "8" -d " ")
echo "NIT_ACTUAL_PID = $NIT_ACTUAL_PID"

NIT_ACTUAL_VERSION=$(grep -A 1 "NIT Actual" "$OUTPUT_TSP_PSI_FILE" | grep "Version" | cut -f "4" -d " " | cut -f "1" -d ",")
echo "NIT_ACTUAL_VERSION = $NIT_ACTUAL_VERSION"

echo "-------------------------------------------------------------------------------"

BAT_PID=$(grep -B 11 "All services" "$OUTPUT_TSP_PSI_FILE" | grep PID | cut -f "7" -d " ")
echo "BAT_PID = $BAT_PID"

BAT_VERSION=$(grep -B 11 "All services" "$OUTPUT_TSP_PSI_FILE" | grep "Version" | cut -f "4" -d " " | cut -f "1" -d ",")
echo "BAT_VERSION = $BAT_VERSION"

echo "-------------------------------------------------------------------------------"

# Grepamo SDT ACTUAL PID in VERSION trenutnega MPTS.
SDT_ACTUAL_PID=$(grep "SDT Actual" "$OUTPUT_TSP_PSI_FILE" | cut -f "8" -d " ")
echo "SDT_ACTUAL_PID = $SDT_ACTUAL_PID"

SDT_TABLE_VERSION=$(grep -A 1 "SDT Actual" "$OUTPUT_TSP_PSI_FILE" | grep "Version" | cut -f "4" -d " " | cut -f "1" -d ",")
echo "SDT_ACTUAL_VERSION = $SDT_TABLE_VERSION"

echo "-------------------------------------------------------------------------------"

# Gremo čez vsak SDT OTHER TSID trenutnega MPTS in grepamo še vse vrednosti SDT OTHER PID\VERSION od vseh preostalih TSIDjev.
for SDT_OTHER_TSID in $(seq 101 145)
do
	echo ""
	echo "SDT_OTHER_TSID = $SDT_OTHER_TSID"
	echo "-------------------------------------------------------------------------------"
	
	SDT_OTHER_PID=$(grep -A 3 "SDT Other" "$OUTPUT_TSP_PSI_FILE" | grep -B 3 "Transport Stream Id: $SDT_OTHER_TSID" | grep -w "PID" | cut -f "8" -d " ")
	echo "SDT_OTHER_PID = $SDT_OTHER_PID"
	
	SDT_OTHER_VERSION=$(grep -A 3 "SDT Other" "$OUTPUT_TSP_PSI_FILE" | grep -B 3 "Transport Stream Id: $SDT_OTHER_TSID" | grep -w "Version" | cut -f "4" -d " " | cut -f "1" -d ",")
	echo "SDT_OTHER_VERSION = $SDT_OTHER_VERSION"
	echo ""

echo ""
done
echo "+++"

#--2--#

# Outputamo še TSDATE, ki preverja vrednost TOT in TDT v MPTSJu. Outputamo kar direktno iz te skripte 1, in ne kot prej iz skripte 0.
echo "TSID = $TSID" > "$OUTPUT_TSP_TSDATE_FILE"
echo "-------------------------------------------------------------------------------" >> "$OUTPUT_TSP_TSDATE_FILE"
tsp -I ip "$MPTS" --receive-timeout 5000 -P until --seconds 90 | tsdate --notdt >> "$OUTPUT_TSP_TSDATE_FILE"
tsp -I ip "$MPTS" --receive-timeout 5000 -P until --seconds 90 | tsdate --notot >> "$OUTPUT_TSP_TSDATE_FILE"
echo "" >> "$OUTPUT_TSP_TSDATE_FILE"


