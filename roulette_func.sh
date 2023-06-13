#!/bin/bash
#rodrigo tavares




#-------------------------------------------------
#functions roulette loop
func_rouletteLoop () {
{
echo "START LOOP"
echo "$global_delimiter"
echo "chosen values:" 
echo "global_budget = $global_budget" 
echo "global_wager = $global_wager" 
echo "global_turns = $global_turns"
echo "$global_delimiter" 
echo "END LOOP"
} >> "$global_logfile"
echo "${global_choice[*]}"

    while [[ $global_turns -gt 0 ]] 
	do
        echo "test"
		#reduce turns by 1
		global_turns=$((global_turns-1))
		#increase total bets counter to display at end
		global_betsTotal=$((global_betsTotal+1))

		#get winning number
		global_winning=$(( $RANDOM % 36))
		if [[ $global_winning =~ "${global_choice[*]}" ]]
		then
			
			#add winnings
			global_budget=$((global_budget+$((global_wager * 35))))
			#increase won counter to display at end
			global_betsWon=$((global_betsWon+1))
			#write log
			echo "turn $global_betsTotal / won: $((global_wager * 35)) / balance: $global_budget" >> "$global_logfile"
			echo "$global_delimiter" >> "$global_logfile"

		#if budget reaches 0 stop the game
		else
			if  [[ $global_budget -gt 0 ]]
			then
				global_budget=$((global_budget-global_wager))
			else
				global_budget=$((global_budget-0))
				echo "you lost all your money after $global_betsTotal bets." >> "$global_logfile"
				break
			fi
		fi
	done
}

#-------------------------------------------------
#functions roulette end
func_rouletteEnd (){
    	#calculate percentage since bash cant do floating arithemetics
	
	global_betsPrct=$(
		awk "BEGIN {print (100/$global_betsTotal)*$global_betsWon}"
	)
	#end runtime
	global_runtimeEnd=$(date +%s%N)
	#difference of start and end
	global_runtimeDiff=$(($global_runtimeEnd-$global_runtimeStart))
	#convert to seconds
	global_runtimeDiffSec=$(
		awk "BEGIN { print ($global_runtimeDiff/1000000000) }"
	)
	
	#show results
	echo "Guthaben: $global_budget"
	echo "Gewinne: $(($global_budget-$global_budget))"
	echo "Du hast $global_betsWon von $global_betsTotal Wetten gewonnen. (${global_betsPrct}%)"
	echo "Programm wurde in ${global_runtimeDiffSec}s ausgeführt"
	#write log
	
	{
	echo "Final Balance: $global_budget"
	echo "Profit Made: $(($global_budget-$global_budget))"
	echo "You won $global_betsWon out of $global_betsTotal bets. (${global_betsPrct}%)"
	echo "Program finished after ${global_runtimeDiffSec}s"
	} >> "$global_logfile"
	#if test was done compare to eta time
	if [[ $global_perfTestDone -eq 1 ]]
	then
		#difference from eta to runtime
		global_runtimeToEta=$(
		awk "BEGIN { print ($global_runtimeDiffSec-$global_perfEta) }"
		)
		#log
		echo "Difference to ETA: ${global_runtimeToEta}s" >> "$global_logfile"
	fi
}