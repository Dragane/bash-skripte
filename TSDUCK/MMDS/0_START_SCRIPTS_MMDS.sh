#!/bin/bash

MPTS_DIGITS_ARRAY=({1..24})
for MPTS_DIGITS in ${MPTS_DIGITS_ARRAY[@]}
do
	MPTS="232.200.2.$MPTS_DIGITS:5200"
	/root/tsduck_scripts/MMDS/1_TSP_PSI_OUTPUT_AND_PARSING_MMDS.sh "$MPTS" > /root/outputs/MMDS/PSI_output_parsed/"$MPTS" &
done

echo ""
echo "Waiting 250 seconds for the Transport Stream scan to finish."
sleep 250

cat /root/outputs/MMDS/PSI_output_parsed/232.* > /root/outputs/MMDS/PSI_output_parsed/merged_PSI_output_parsed.txt
cat /root/outputs/MMDS/tsp_tsdate_output/232.* > /root/outputs/MMDS/tsp_tsdate_output/merged_tsp_tsdate_output.txt
/root/tsduck_scripts/MMDS/2_PSI_TABLES_COMPARISON_MMDS.sh

