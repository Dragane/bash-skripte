#!/bin/bash

MPTS_DIGITS_ARRAY=({1..7..2} 8 15 16 19 20 {25..45} 93) # Za enkrat je notri samo .93 lokalni programi. @Vasja, ko jih dodaš, popravi tu v skripti. Preveri še skripto 2.
for MPTS_DIGITS in ${MPTS_DIGITS_ARRAY[@]}
do
	MPTS="232.205.1.$MPTS_DIGITS:5200"
	/root/tsduck_scripts/D3_Plan_A/1_TSP_PSI_OUTPUT_AND_PARSING_D3_Plan_A.sh "$MPTS" > /root/outputs/D3_Plan_A/PSI_output_parsed/"$MPTS" &
done

echo ""
echo "Waiting 250 seconds for the Transport Stream scan to finish."
sleep 250

#cat /root/outputs/D3_Plan_A/PSI_output_parsed/232.* > /root/outputs/D3_Plan_A/PSI_output_parsed/merged_PSI_output_parsed.txt
#cat /root/outputs/D3_Plan_A/tsp_tsdate_output/232.* > /root/outputs/D3_Plan_A/tsp_tsdate_output/merged_tsp_tsdate_output.txt
/root/tsduck_scripts/D3_Plan_A/2_PSI_TABLES_COMPARISON_D3_novi.sh

