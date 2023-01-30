#!/bin/bash
#rodrigo tavares




func_perfTest (){
    perf_logfile="roulette_logs/roulette_perfTest_$(date +%Y-%m-%d_%H%M%S).log"
    perf_budget=1000000000
    perf_wager=1
    perf_turns=10000000
    perf_delimiter="-"
    perf_betsTotal=0
    perf_choice=0
    echo "$perf_delimiter" >> $perf_logfile
    perf_runtimeStart=$(date +%s%N)
    while [[ $perf_turns>0 ]]
    do
       
        let perf_turns=perf_turns-1
        let perf_betsTotal=perf_betsTotal+1

        perf_winning=$(( $RANDOM % 36))
        if [[ $perf_winning = $perf_choice ]]
		then
			
			#add winnings
			let perf_budget=perf_budget+$((perf_wager * 35))
			#increase won counter to display at end
			#let perf_betsWon=perf_betsWon+1
			echo "Turn $perf_betsTotal" >> $perf_logfile
			echo "You Won: $((perf_wager * 35))" >> $perf_logfile
			echo "Current Balance: $perf_budget" >> $perf_logfile
			echo "$perf_delimiter" >> $perf_logfile
			

		#if budget reaches 0 stop the game
		else
			if  [[ $perf_budget > 0 ]]
			then
				let perf_budget=perf_budget-perf_wager
			else
				let perf_budget=perf_budget-0
				break
			fi
		fi
        perf_runtimeEnd=$(date +%s%N)
        perf_runtimeDiff=$(($perf_runtimeEnd - $perf_runtimeStart))
        if [[ $perf_runtimeDiff -gt 1000000000 ]]
        then
            global_perfScore=$perf_betsTotal
            echo "Your performance Score is: $perf_betsTotal bets per second" >> $perf_logfile
            break
        else
            perf_dummyVar=0
        fi

    done
}




