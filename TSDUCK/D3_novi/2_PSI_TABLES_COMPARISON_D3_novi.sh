#!/bin/bash

MPTS_DIGITS_ARRAY=({1..20} {25..45} {93..99})

for MPTS_DIGITS in ${MPTS_DIGITS_ARRAY[@]}
do
	MPTS="232.204.1.$MPTS_DIGITS:5200"
	INPUT_TSP_PSI_FILE="/root/outputs/D3_novi/PSI_output_parsed/$MPTS"
	INPUT_TSP_TSDATE_FILE="/root/outputs/D3_novi/tsp_tsdate_output/$MPTS"
	
	if [[ "$MPTS_DIGITS" -gt 45 ]]
	then
		TSID=132
	else
		TSID=$(($MPTS_DIGITS+100))
	fi
	
	CURRENT_TSID_STRING=$(grep -w "TSID = $TSID" $INPUT_TSP_PSI_FILE) # V spremenljivko damo output komande. Output npr. TSID = 101.

	if [ -n "$CURRENT_TSID_STRING" ]  # Če v develop_output.txt obstaja string TSID = n"
	then
		CAT_PID_FROM_CURRENT_TSID=$(grep "CAT_PID" $INPUT_TSP_PSI_FILE | cut -f "3" -d " ")
		CAT_VERSION_FROM_CURRENT_TSID=$(grep "CAT_TABLE_VERSION" $INPUT_TSP_PSI_FILE | cut -f "3" -d " ")
		NIT_PID_FROM_CURRENT_TSID=$(grep "NIT_ACTUAL_PID" $INPUT_TSP_PSI_FILE | cut -f "3" -d " ")
		NIT_VERSION_FROM_CURRENT_TSID=$(grep "NIT_ACTUAL_VERSION" $INPUT_TSP_PSI_FILE | cut -f "3" -d " ")
		BAT_PID_FROM_CURRENT_TSID=$(grep "BAT_PID" $INPUT_TSP_PSI_FILE | cut -f "3" -d " ")
		BAT_VERSION_FROM_CURRENT_TSID=$(grep "BAT_VERSION" $INPUT_TSP_PSI_FILE | cut -f "3" -d " ")
	    SDT_ACTUAL_PID=$(grep "SDT_ACTUAL_PID" $INPUT_TSP_PSI_FILE | cut -f "3" -d " ")
		SDT_ACTUAL_VERSION=$(grep "SDT_ACTUAL_VERSION" $INPUT_TSP_PSI_FILE | cut -f "3" -d " ")
		TDT_FROM_CURRENT_TSID=$(grep -w "TDT" $INPUT_TSP_TSDATE_FILE)
		TOT_FROM_CURRENT_TSID=$(grep -w "TOT" $INPUT_TSP_TSDATE_FILE)
		
		echo ""
		echo "*********** Scanning $MPTS, $CURRENT_TSID_STRING ************"
		
		if [ -z "$TDT_FROM_CURRENT_TSID" ]
		then
			echo "TDT from TSID $TSID is missing!"
		#else
		#	echo "TDT_FROM_CURRENT_TSID = $TDT_FROM_CURRENT_TSID"
		fi
		
		if [ -z "$TOT_FROM_CURRENT_TSID" ]
		then
			echo "TOT from TSID $TSID is missing!"
		#else
		#	echo "TOT_FROM_CURRENT_TSID = $TOT_FROM_CURRENT_TSID"
		fi
		
		for OTHER_MPTS_DIGITS in ${MPTS_DIGITS_ARRAY[@]}
		do
			OTHER_MPTS="232.204.1.$OTHER_MPTS_DIGITS:5200"
			INPUT_TSP_PSI_FILE="/root/outputs/D3_novi/PSI_output_parsed/$OTHER_MPTS"
			
			if [[ "$OTHER_MPTS_DIGITS" -gt 45 ]]
			then
				OTHER_TSID=132
			else
				OTHER_TSID=$(($OTHER_MPTS_DIGITS+100))
			fi
			
			OTHER_TSID_STRING=$(grep -w "TSID = $OTHER_TSID" $INPUT_TSP_PSI_FILE) # Ponovno išćemo v "TSID = n" develop_output.txt 			
			if [[ "$OTHER_TSID" -ne "$TSID" ]] && [[ -n "$OTHER_TSID_STRING" ]] # Če OTHER TSID ni enak ACTUAL TSID in če OTHER TSID obstaja...
			then
				CAT_PID_FROM_OTHER_TSID_STRING=$(grep "CAT_PID" "$INPUT_TSP_PSI_FILE" | cut -f "3" -d " ")
				CAT_VERSION_FROM_OTHER_TSID_STRING=$(grep "CAT_TABLE_VERSION" "$INPUT_TSP_PSI_FILE" | cut -f "3" -d " ")
				NIT_PID_FROM_OTHER_TSID_STRING=$(grep "NIT_ACTUAL_PID" "$INPUT_TSP_PSI_FILE" | cut -f "3" -d " ")
				NIT_VERSION_FROM_OTHER_TSID_STRING=$(grep "NIT_ACTUAL_VERSION" "$INPUT_TSP_PSI_FILE" | cut -f "3" -d " ")	
				BAT_PID_FROM_OTHER_TSID_STRING=$(grep "BAT_PID" "$INPUT_TSP_PSI_FILE" | cut -f "3" -d " ")	
				BAT_VERSION_FROM_OTHER_TSID_STRING=$(grep "BAT_VERSION" "$INPUT_TSP_PSI_FILE" | cut -f "3" -d " ")				
				SDT_OTHER_PID=$(sed -n "/\SDT_OTHER_TSID = $TSID\>/,/^ *$/p" "$INPUT_TSP_PSI_FILE" | grep -w "SDT_OTHER_PID" | cut -f "3" -d " ")
				SDT_OTHER_VERSION=$(sed -n "/\SDT_OTHER_TSID = $TSID\>/,/^ *$/p" "$INPUT_TSP_PSI_FILE" | grep -w "SDT_OTHER_VERSION" | cut -f "3" -d " ")
				
				if [[ "$CAT_PID_FROM_CURRENT_TSID" -ne "$CAT_PID_FROM_OTHER_TSID_STRING" ]] #Morajo biti dvojni oklepaji, drugače ob prazni vrednosti javlja "expected integer".
				then
					echo "MISSMATCH DETECTED: CAT PID from TSID$TSID = $CAT_PID_FROM_CURRENT_TSID and CAT PID from TSID$OTHER_TSID = $CAT_PID_FROM_OTHER_TSID_STRING"
				#else 
					#echo "TS$MPTS_DIGITS CAT PID = $CAT_PID_FROM_CURRENT_TSID and TS$OTHER_TSID = $CAT_PID_FROM_OTHER_TSID_STRING"
				fi
				
				if [[ "$CAT_VERSION_FROM_CURRENT_TSID" -ne "$CAT_VERSION_FROM_OTHER_TSID_STRING" ]]
				then	
					echo "MISSMATCH DETECTED: CAT Version from TSID$TSID = $CAT_VERSION_FROM_CURRENT_TSID and CAT Version from TS$OTHER_TSID = $CAT_VERSION_FROM_OTHER_TSID_STRING"
				#else 
					#echo "TS$MPTS_DIGITS CAT Version = $CAT_VERSION_FROM_CURRENT_TSID and TS$OTHER_TSID CAT Version = $CAT_VERSION_FROM_OTHER_TSID_STRING"
				fi
				
				if [[ "$NIT_PID_FROM_CURRENT_TSID" -ne "$NIT_PID_FROM_OTHER_TSID_STRING" ]]
				then
					echo "MISSMATCH DETECTED: NIT PID from TSID$TSID = $NIT_PID_FROM_CURRENT_TSID and NIT PID from TSID$OTHER_TSID = $NIT_PID_FROM_OTHER_TSID_STRING"
				#else 
					#echo "TS$MPTS_DIGITS NIT PID = $NIT_PID_FROM_CURRENT_TSID and TS$OTHER_TSID = $NIT_PID_FROM_OTHER_TSID_STRING"
				fi
				
				if [[ "$NIT_VERSION_FROM_CURRENT_TSID" -ne "$NIT_VERSION_FROM_OTHER_TSID_STRING" ]]
				then
					echo "MISSMATCH DETECTED: NIT Version from TSID$TSID = $NIT_VERSION_FROM_CURRENT_TSID and NIT Version from TSID$OTHER_TSID = $NIT_VERSION_FROM_OTHER_TSID_STRING"
				#else 
					#echo "TS$MPTS_DIGITS NIT Version = $NIT_VERSION_FROM_CURRENT_TSID and TS$OTHER_TSID NIT Version = $NIT_VERSION_FROM_OTHER_TSID_STRING"
				fi
				
				if [[ "$BAT_PID_FROM_CURRENT_TSID" -ne "$BAT_PID_FROM_OTHER_TSID_STRING" ]] 
				then
					echo "MISSMATCH DETECTED: BAT PID from TSID$TSID = $BAT_PID_FROM_CURRENT_TSID and BAT PID from TSID$OTHER_TSID = $BAT_PID_FROM_OTHER_TSID_STRING"
				#else 
					#echo "TS$MPTS_DIGITS BAT PID = $BAT_PID_FROM_CURRENT_TSID and TS$OTHER_TSID = $BAT_PID_FROM_OTHER_TSID_STRING"
				fi
				
				if [[ "$BAT_VERSION_FROM_CURRENT_TSID" -ne "$BAT_VERSION_FROM_OTHER_TSID_STRING" ]]
				then
					echo "MISSMATCH DETECTED: BAT VERSION from TSID$TSID = $BAT_VERSION_FROM_CURRENT_TSID and BAT VERSION from TSID$OTHER_TSID = $BAT_VERSION_FROM_OTHER_TSID_STRING"
				#else 
					#echo "TS$MPTS_DIGITS BAT Version = $BAT_VERSION_FROM_CURRENT_TSID and TS$OTHER_TSID = $BAT_VERSION_FROM_OTHER_TSID_STRING"
				fi
				
				if [[ "$SDT_ACTUAL_PID" -ne "$SDT_OTHER_PID" ]]
				then
					echo "MISSMATCH DETECTED: SDT Actual PID from TSID$TSID = $SDT_ACTUAL_PID and SDT Other PID from TSID$OTHER_TSID = $SDT_OTHER_PID"
				#else 
					#echo "TS$MPTS_DIGITS SDT Actual PID = $SDT_ACTUAL_PID and TS$OTHER_TSID = $SDT_OTHER_PID"
				fi
				
				if [[ "$SDT_ACTUAL_VERSION" -ne "$SDT_OTHER_VERSION" ]]
				then
					echo "MISSMATCH DETECTED: SDT Actual Version from TSID$TSID = $SDT_ACTUAL_VERSION and SDT Other Version from TSID$OTHER_TSID = $SDT_OTHER_VERSION"
				#else 
				#	echo "TS$MPTS_DIGITS SDT Actual Version = $SDT_ACTUAL_VERSION and TS$OTHER_TSID = $SDT_OTHER_VERSION"
				fi
				
			fi
		done
	else
		echo "!!Entry: \"TSID = $TSID\" doesn't exist in $INPUT_TSP_PSI_FILE!!" 
		
	fi
done
