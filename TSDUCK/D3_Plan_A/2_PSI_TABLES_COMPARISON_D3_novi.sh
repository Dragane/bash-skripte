#!/bin/bash
	# 1. Naredimo for loop z vsemi MPTS IPji, da gremo skozi vse PSI_output_parsed in tsp_tsdate_output fajle. Vsak loop bo druga vrednost MPTS. V Vsakem loopu pridobi podatke navedene v naslednih točkah:
	# 2. CAT Version\PID, NIT Version\PID, BAT Version\PID, SDT Actual Version\PID, TDT\TOT.
	# 3. Nato z if funkcijo preverimo, če TDT\TOT tabela v tem MPTS obstaja.
	# 4. Naredimo še loop2 gnezden znotraj loopa1. Ponovno gremo skozi vse PSI_output_parsed fajle. V vsakem izmed teh fajlov grepamo SDT Other Version\PID od MPTSja iz loop1 ter grepamo še
	# CAT Version\PID, NIT Version\PID, BAT Version\PID iz MPTSja iz loop2.
	# 5. Nato še vedno znotraj loopa2 izvdemo primerjavo SDT Actual PID\Version s SDT Other PID\Version ter pogledamo, če so CAT, NIT, BAT Version\PID enaki. 


#--1--#
MPTS_DIGITS_ARRAY=({1..7..2} 8 15 16 19 20 {25..45} 93) # Array z vsemi zadnjimi ciframi od IP MPTSjev. @Vasja dodaj lokalne MPTSje tu.

for MPTS_DIGITS in ${MPTS_DIGITS_ARRAY[@]}
do
	MPTS="232.205.1.$MPTS_DIGITS:5200" # MPTS IP
	INPUT_TSP_PSI_FILE="/root/outputs/D3_Plan_A/PSI_output_parsed/$MPTS" # TSP PSI log file, ki je lepo urejen, iz skripte 1).
	INPUT_TSP_TSDATE_FILE="/root/outputs/D3_Plan_A/tsp_tsdate_output/$MPTS" # TSP TSDATE file iz skripte 1.
	
	# Če je zadnja cifra v MPTS IP večja kot 46, pomeni, da gre za lokalne kanale, ki so vsi v TSID  = 132. Drugače je TSID 100 + zadnje cifre MPTS IPja. 
	if [[ "$MPTS_DIGITS" -gt 46 ]]
	then
		TSID=132
	else
		TSID=$(($MPTS_DIGITS+100))
	fi
		
	
	CURRENT_TSID_STRING=$(grep -w "TSID = $TSID" $INPUT_TSP_PSI_FILE) # Grepnemo TSID iz output fajla inga damo v spremenljivko. TSID mora biti 100 + cifra MPTS, drugače bo to prazna spremenljivka.

	#--2--#
	if [ -n "$CURRENT_TSID_STRING" ]  # Če spremenljivka NI prazna (-n), torej, če je TSID pravilen/obstaja, izvedi spodnjo kodo.
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
		
		#--3--#
		if [ -z "$TDT_FROM_CURRENT_TSID" ] # Preverba, če obstaja TDT. Če JE spremenljivka prazna (-z), potem izpiši...
		then
			echo "TDT from TSID $TSID is missing!"
		#else
		#	echo "TDT_FROM_CURRENT_TSID = $TDT_FROM_CURRENT_TSID"
		fi
		
		if [ -z "$TOT_FROM_CURRENT_TSID" ] # Preverba, če obstaja TOT. Če JE spremenljivka prazna (-z), potem izpiši...
		then
			echo "TOT from TSID $TSID is missing!"
		#else
		#	echo "TOT_FROM_CURRENT_TSID = $TOT_FROM_CURRENT_TSID"
		fi
		
		# Še enkrat naredimo loop po vseh fajlih TSP_PSI_FILE
		for OTHER_MPTS_DIGITS in ${MPTS_DIGITS_ARRAY[@]}
		do
			OTHER_MPTS="232.205.1.$OTHER_MPTS_DIGITS:5200"
			INPUT_TSP_PSI_FILE="/root/outputs/D3_Plan_A/PSI_output_parsed/$OTHER_MPTS"
			
			if [[ "$OTHER_MPTS_DIGITS" -gt 46 ]]
			then
				OTHER_TSID=132
			else
				OTHER_TSID=$(($OTHER_MPTS_DIGITS+100))
			fi
			
			OTHER_TSID_STRING=$(grep -w "TSID = $OTHER_TSID" $INPUT_TSP_PSI_FILE) # Ponovno išćemo "TSID = n" v MPTSju iz loopa2.
			if [[ "$OTHER_TSID" -ne "$TSID" ]] && [[ -n "$OTHER_TSID_STRING" ]] # Če OTHER TSID (loop2) ni enak ACTUAL TSID (loop1) in če OTHER TSID obstaja, potem nadaljuj funkcijo.
			then
				CAT_PID_FROM_OTHER_TSID_STRING=$(grep "CAT_PID" "$INPUT_TSP_PSI_FILE" | cut -f "3" -d " ")
				CAT_VERSION_FROM_OTHER_TSID_STRING=$(grep "CAT_TABLE_VERSION" "$INPUT_TSP_PSI_FILE" | cut -f "3" -d " ")
				NIT_PID_FROM_OTHER_TSID_STRING=$(grep "NIT_ACTUAL_PID" "$INPUT_TSP_PSI_FILE" | cut -f "3" -d " ")
				NIT_VERSION_FROM_OTHER_TSID_STRING=$(grep "NIT_ACTUAL_VERSION" "$INPUT_TSP_PSI_FILE" | cut -f "3" -d " ")
				BAT_PID_FROM_OTHER_TSID_STRING=$(grep "BAT_PID" "$INPUT_TSP_PSI_FILE" | cut -f "3" -d " ")
				BAT_VERSION_FROM_OTHER_TSID_STRING=$(grep "BAT_VERSION" "$INPUT_TSP_PSI_FILE" | cut -f "3" -d " ")
				SDT_OTHER_PID=$(sed -n "/\SDT_OTHER_TSID = $TSID\>/,/^ *$/p" "$INPUT_TSP_PSI_FILE" | grep -w "SDT_OTHER_PID" | cut -f "3" -d " ")
				SDT_OTHER_VERSION=$(sed -n "/\SDT_OTHER_TSID = $TSID\>/,/^ *$/p" "$INPUT_TSP_PSI_FILE" | grep -w "SDT_OTHER_VERSION" | cut -f "3" -d " ")
				
				#--5--#
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
