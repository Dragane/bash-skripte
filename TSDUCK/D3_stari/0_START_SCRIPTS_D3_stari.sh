#!/bin/bash

MPTS_DIGITS_ARRAY=({1..44} {94..99})
for MPTS_DIGITS in ${MPTS_DIGITS_ARRAY[@]}
do
	MPTS="232.200.1.$MPTS_DIGITS:5200"
	/root/tsduck_scripts/D3_stari/1_TSP_PSI_OUTPUT_AND_PARSING_D3_stari.sh "$MPTS" > /root/outputs/D3_stari/PSI_output_parsed/"$MPTS" &
done

echo ""
echo "Waiting 250 seconds for the Transport Stream scan to finish."
sleep 250

cat /root/outputs/D3_stari/PSI_output_parsed/232.* > /root/outputs/D3_stari/PSI_output_parsed/merged_PSI_output_parsed.txt
cat /root/outputs/D3_stari/tsp_tsdate_output/232.* > /root/outputs/D3_stari/tsp_tsdate_output/merged_tsp_tsdate_output.txt
/root/tsduck_scripts/D3_stari/2_PSI_TABLES_COMPARISON_D3_stari.sh

