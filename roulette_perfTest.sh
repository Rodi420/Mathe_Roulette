#!/bin/bash
# Rodrigo Tavares




func_perfTest (){
    #perf_logfile="roulette_logs/roulette_perfTest_$(date +%Y-%m-%d_%H%M%S).log"
    perf_budget=1000000000
    perf_wager=1
    # Test with 10000 turns, runtime method not working as intended
    perf_turns=10000
    perf_delimiter="-"
    perf_betsTotal=0
    perf_choice=0
    echo "$perf_delimiter" >> $perf_logfile
    perf_runtimeStart=$(date +%s%N)
    for ((i=0; i<perf_turns && perf_budget>0; i++)); do

        # Increase total bets counter to display at end
        #perf_betsTotal=$((perf_betsTotal+1))
        #printf "\rCurrent Bet: %d | Current Wins: %d" "$perf_betsTotal" "$perf_betsWon"
        

        # Get winning number
        perf_winning=$(( $RANDOM % 37))

        if [[ $main_mode -eq 1 && $perf_winning -eq $perf_choice ]]; then
            perf_budget=$((perf_budget+$((perf_wager * 35))))
            perf_betsWon=$((perf_betsWon+1))
        elif [[ $main_mode -eq 2 ]] && (( perf_winning % 2 == 0 )) && (( perf_winning != 0 )); then
            perf_budget=$((perf_budget+$((perf_wager * 2))))
            perf_betsWon=$((perf_betsWon+1))
        elif [[ $main_mode -eq 3 ]] && (( perf_winning % 2 == 1 )); then
			perf_budget=$((perf_budget+$((perf_wager * 2))))
			perf_betsWon=$((perf_betsWon+1))
		elif [[ $main_mode -eq 4 ]] && (( perf_winning >= 1 && perf_winning <= 9)); then
			perf_budget=$((perf_budget+$((perf_wager * 4))))
			perf_betsWon=$((perf_betsWon+1))			
		fi
        perf_budget=$((perf_budget-perf_wager))

    done
    #printf "\n"
    perf_runtimeEnd=$(date +%s%N)
    perf_runtimeDiff=$(($perf_runtimeEnd - $perf_runtimeStart))
    
    perf_runtimeDiffSec=$(
		awk "BEGIN { print ($perf_runtimeDiff/1000000000) }"
	)
    #echo "Your performance Score is: $perf_betsTotal bets per second" >> $perf_logfile
    echo "Your Computer took ${perf_runtimeDiff}ns or ${perf_runtimeDiffSec}s to finish 10000 Turns" >> "$perf_logfile"
    perf_betsPerSec=$(
		awk "BEGIN { print (10000/$perf_runtimeDiffSec) }"
	)
    echo "Your Performance score is: $perf_betsPerSec bets per second" >> "$perf_logfile"
}




