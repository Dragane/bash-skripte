#!/bin/bash

MPTS_DIGITS_ARRAY=({1..20} {25..45} {93..99}) # 93-99 so lokalni
for MPTS_DIGITS in ${MPTS_DIGITS_ARRAY[@]}
do
	MPTS="232.204.1.$MPTS_DIGITS:5200"
	/root/tsduck_scripts/D3_novi/1_TSP_PSI_OUTPUT_AND_PARSING_D3_novi.sh "$MPTS" > /root/outputs/D3_novi/PSI_output_parsed/"$MPTS" &
done

echo ""
echo "Waiting 250 seconds for the Transport Stream scan to finish."
sleep 250

cat /root/outputs/D3_novi/PSI_output_parsed/232.* > /root/outputs/D3_novi/PSI_output_parsed/merged_PSI_output_parsed.txt
cat /root/outputs/D3_novi/tsp_tsdate_output/232.* > /root/outputs/D3_novi/tsp_tsdate_output/merged_tsp_tsdate_output.txt
/root/tsduck_scripts/D3_novi/2_PSI_TABLES_COMPARISON_D3_novi.sh

