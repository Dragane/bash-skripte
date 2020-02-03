#!/bin/bash

MPTS=$1
OUTPUT_TSP_PSI_FILE="/root/outputs/D3_novi/tsp_PSI_output/$MPTS"
OUTPUT_TSP_TSDATE_FILE="/root/outputs/D3_novi/tsp_tsdate_output/$MPTS"

tsp -I ip "$MPTS" --receive-timeout 5000 -P psi --all-versions -P until --seconds 120 -O drop > "$OUTPUT_TSP_PSI_FILE"

 
TSID=$(grep -A 3 "SDT Actual" "$OUTPUT_TSP_PSI_FILE" | grep "Transport Stream Id" | cut -f "8" -d " ")

echo ""
echo "$MPTS"
echo "-------------------------------------------------------------------------------"
echo "TSID = $TSID"
echo "-------------------------------------------------------------------------------"

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

SDT_ACTUAL_PID=$(grep "SDT Actual" "$OUTPUT_TSP_PSI_FILE" | cut -f "8" -d " ")
echo "SDT_ACTUAL_PID = $SDT_ACTUAL_PID"

SDT_TABLE_VERSION=$(grep -A 1 "SDT Actual" "$OUTPUT_TSP_PSI_FILE" | grep "Version" | cut -f "4" -d " " | cut -f "1" -d ",")
echo "SDT_ACTUAL_VERSION = $SDT_TABLE_VERSION"

echo "-------------------------------------------------------------------------------"

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


echo "TSID = $TSID" > "$OUTPUT_TSP_TSDATE_FILE"
echo "-------------------------------------------------------------------------------" >> "$OUTPUT_TSP_TSDATE_FILE"
tsp -I ip "$MPTS" --receive-timeout 5000 -P until --seconds 90 | tsdate --notdt >> "$OUTPUT_TSP_TSDATE_FILE"
tsp -I ip "$MPTS" --receive-timeout 5000 -P until --seconds 90 | tsdate --notot >> "$OUTPUT_TSP_TSDATE_FILE"
echo "" >> "$OUTPUT_TSP_TSDATE_FILE"


