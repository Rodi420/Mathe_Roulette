#!/bin/bash
# Rodrigo Tavares




#-------------------------------------------------
# Functions roulette loop

func_rouletteLoop () {
	
	# Set variables
	global_betsWon=0
	global_betsTotal=0
	
	{
	echo "START LOOP"
	echo "$global_delimiter"
	} >> "$global_logfile"

	global_runtimeStart=$(date +%s%N)
    for ((global_betsTotal=0; global_betsTotal<global_turns && global_budget>0; global_betsTotal++)); do

		# Increase total bets counter
		#global_betsTotal=$((global_betsTotal+1))
		# Used in combination with bets displayer
		# Over 1 million bets this takes it from 9.5 seconds to 45 seconds (4.75x slower)
		#printf "\rCurrent Bet: %d | Current Wins: %d" "$global_betsTotal" "$global_betsWon"
		
		# Get winning number
		global_winning=$(( $RANDOM % 37))

		if [[ $main_mode -eq 1 && $global_winning -eq $global_choice ]]; then
			# Add winnings
			global_budget=$((global_budget+$((global_wager * 35))))
			# Increase won counter to display at end
			global_betsWon=$((global_betsWon+1))
			# Write log
			#echo "$global_delimiter" >> "$global_logfile"
			#echo -e "turn $global_betsTotal / winning number: $global_winning / won: $((global_wager * 35)) / balance: $global_budget" >> "$global_logfile"
			# Each opening of file 2x the amount of processing
		elif [[ $main_mode -eq 2 ]] && (( global_winning % 2 == 0 )) && (( global_winning != 0 )); then
			# Add winnings
			global_budget=$((global_budget+$((global_wager * 2))))
			# Increase won counter to display at end
			global_betsWon=$((global_betsWon+1))
		elif [[ $main_mode -eq 3 ]] && (( global_winning % 2 == 1 )); then
			global_budget=$((global_budget+$((global_wager * 2))))
			global_betsWon=$((global_betsWon+1))
		elif [[ $main_mode -eq 4 ]] && (( global_winning >= global_rowOne && global_winning <= global_rowTwo)); then
			global_budget=$((global_budget+$((global_wager * 4))))
			global_betsWon=$((global_betsWon+1))			
		fi
		global_budget=$((global_budget-global_wager))

	done
	#printf "\n"
	
	if [[ $global_budget -le 0 ]]; then
		echo -e "Du hast dein ganzes Guthaben nach $global_betsTotal Wetten verloren."
    	echo "you lost all your money after $global_betsTotal bets." >> "$global_logfile"
	fi

	{
	echo "END LOOP"
	echo "$global_delimiter" 
	} >> "$global_logfile"
}

#-------------------------------------------------
# Functions roulette end
func_rouletteEnd (){
	
    # Calculate percentage since bash cant do floating arithemetics
	global_betsPrct=$(
		awk "BEGIN {print (100/$global_betsTotal)*$global_betsWon}"
	)
	# End runtime
	global_runtimeEnd=$(date +%s%N)
	# Difference of start and end
	global_runtimeDiff=$(($global_runtimeEnd-$global_runtimeStart))
	# Convert to seconds
	global_runtimeDiffSec=$(
		awk "BEGIN { print ($global_runtimeDiff/1000000000) }"
	)
	
	# Show results
	printf '%100s\n' | tr ' ' -
	echo "Guthaben: $global_budget"
	echo "Gewinne: $(($global_budget-$global_budgetOri))"
	echo "Du hast $global_betsWon von $global_betsTotal Wetten gewonnen. (${global_betsPrct}%)"
	echo "Programm wurde in ${global_runtimeDiffSec}s ausgeführt"
	printf '%100s\n' | tr ' ' -
	
	# Write log
	{
	echo "Final Balance: $global_budget"
	echo "Profit Made: $(($global_budget-$global_budgetOri))"
	echo "You won $global_betsWon out of $global_betsTotal bets. (${global_betsPrct}%)"
	echo "Program finished after ${global_runtimeDiffSec}s"
	} >> "$global_logfile"
	# If test was done compare to eta time
	if [[ $global_perfTestDone -eq 1 ]]; then
		# Difference from eta to runtime
		global_runtimeToEta=$(
		awk "BEGIN { print ($global_runtimeDiffSec-$global_perfEta) }"
		)
		# Log
		echo "Difference to ETA: ${global_runtimeToEta}s" >> "$global_logfile"
	fi
}