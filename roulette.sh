#!/bin/bash
#rodrigo tavares
#version 2.0
#overhaul of entire script. remade from scratch with options, dynamic variables, modes and logging.

#static variables
#global_budget=1000
#global_wager=10
#global_turns=1000
source ./roulette_perfTest.sh

global_logfile="roulette_logs/roulette_$(date +%Y-%m-%d_%H%M%S).log"
perf_logfile="roulette_logs/roulette_perfTest_$(date +%Y-%m-%d_%H%M%S).log"
global_delimiter="-"



#make log directory if it doesnt exist
if [[ ! -d roulette_logs ]]
then
    mkdir roulette_logs
	echo "$global_delimiter" >> $global_logfile
    echo "info: logs directory does not exist. creating it..." >> $global_logfile
#if it exists write to log
else
	echo "$global_delimiter" >> $global_logfile
	echo "info: logs directory exists already." >> $global_logfile
fi

#start
clear
echo -e "Willkommen bei Roulette. Definiere deine Standardwerte:"

#define variables
read -p "Dein Budget: " global_budget
read -p "Dein Einsatz pro Spiel: " global_wager
read -p "Wie viel mal willst du spielen? " global_turns

#write log
echo "$global_delimiter" >> $global_logfile
echo "chosen values:" >> $global_logfile
echo "global_budget = $global_budget" >> $global_logfile
echo "global_wager = $global_wager" >> $global_logfile
echo "global_turns = $global_turns" >> $global_logfile
echo "$global_delimiter" >> $global_logfile
clear

#performance test
echo -e "Willst du einen Performance Test durchführen?\n1. Ja\n2. Nein"
read -p "Eingabe: " global_perfTest

if [[ $global_perfTest -eq 1 ]]
then
	#do perf test
	func_perfTest
	global_perfTestDone=1
	echo "performance Test done. Resuming..." >> $global_logfile
else
	echo "performance Test not done. Resuming..." >> $global_logfile
	#this variable value is called nowhere**
	global_perfTestDone=0
fi

if [[ $global_turns -gt 10000 ]]
then
	echo -e "Hinweis:\nDu hast mehr als 10'000 Spiele ausgewählt.\nEs kann länger dauern bis das Programm fertig ist!"
	echo -e "more than 10000 Turns selected. Proceed with caution." >> $global_logfile
else
	echo -e "less than 10000 Turns selected. Proceed allowed." >> $global_logfile
fi
if [[ $global_perfTestDone -eq 1 ]]
then
	echo -e "\nEs wurde ein Performance Test durchgeführt."
	#calculate eta runtime
	global_perfEta=$(
		awk "BEGIN { print ($global_turns/$perf_betsPerSec) }"
	)
	echo -e "Geschätzte Dauer der Durchführung dieses Programmes: ${global_perfEta}s"
	echo -e "ETA: ${global_perfEta}s" >> $global_logfile
else
	echo -e "Es wurde kein Performance Test durchgeführt."
fi

echo -e "\nWähle ein Spielmodus\n1. Einzelnummern\n2. Even\n3. Odd\n4. Row"
read -p "Eingabe: " main_mode

if [[ $main_mode -eq 1 ]]
then

	#take input
	echo ""
	read -p "Auf welche Zahl willst du wetten? " solo_choice

	#mode speficic variables
	solo_budget=$global_budget
	solo_betsWon=0
	solo_betsTotal=0
	solo_runtimeStart=$(date +%s%N)
	#write log
	echo "mode chosen: $main_mode" >> $global_logfile
	echo "solo_budget = $solo_budget" >> $global_logfile
	echo "$global_delimiter" >> $global_logfile
	
	while [[ $global_turns>0 ]] 
	do
		#reduce turns by 1
		let global_turns=global_turns-1
		#increase total bets counter to display at end
		let solo_betsTotal=solo_betsTotal+1

		#get winning number
		solo_winning=$(( $RANDOM % 36))
		if [[ $solo_winning = $solo_choice ]]
		then
			
			#add winnings
			let solo_budget=solo_budget+$((global_wager * 35))
			#increase won counter to display at end
			let solo_betsWon=solo_betsWon+1
			#write log
			#echo "turn $solo_betsTotal" >> $global_logfile
			#echo "won: $((global_wager * 35))" >> $global_logfile
			#echo "balance: $solo_budget" >> $global_logfile
			#optimized version of write log
			echo "turn $solo_betsTotal / won: $((global_wager * 35)) / balance: $solo_budget" >> $global_logfile
			echo "$global_delimiter" >> $global_logfile

		#if budget reaches 0 stop the game
		else
			if  [[ $solo_budget > 0 ]]
			then
				let solo_budget=solo_budget-global_wager
			else
				let solo_budget=solo_budget-0
				echo "you lost all your money after $solo_betsTotal bets." >> $global_logfile
				break
			fi
		fi
	done
	#calculate percentage since bash cant do floating arithemetics
	
	solo_betsPrct=$(
		awk "BEGIN {print (100/$solo_betsTotal)*$solo_betsWon}"
	)
	#end runtime
	solo_runtimeEnd=$(date +%s%N)
	#difference of start and end
	solo_runtimeDiff=$(($solo_runtimeEnd - $solo_runtimeStart))
	#convert to seconds
	solo_runtimeDiffSec=$(
		awk "BEGIN { print ($solo_runtimeDiff/1000000000) }"
	)
	
	#show results
	echo "Guthaben: $solo_budget"
	echo "Gewinne: $(($solo_budget-$global_budget))"
	echo "Du hast $solo_betsWon von $solo_betsTotal Wetten gewonnen. (${solo_betsPrct}%)"
	echo "Programm wurde in ${solo_runtimeDiffSec}s ausgeführt"
	#write log
	echo "Final Balance: $solo_budget" >> $global_logfile
	echo "Profit Made: $(($solo_budget-$global_budget))" >> $global_logfile
	echo "You won $solo_betsWon out of $solo_betsTotal bets. (${solo_betsPrct}%)" >> $global_logfile
	echo "Program finished after ${solo_runtimeDiffSec}s" >> $global_logfile
	#if test was done compare to eta time
	if [[ $global_perfTestDone -eq 1 ]]
	then
		#difference from eta to runtime
		solo_runtimeToEta=$(
		awk "BEGIN { print ($solo_runtimeDiffSec-$global_perfEta) }"
		)
		#log
		echo "Difference to ETA: ${solo_runtimeToEta}s" >> $global_logfile
	fi
elif [[ $main_mode -eq 2 ]] 
then
	echo "even"

else
	echo "error"
fi