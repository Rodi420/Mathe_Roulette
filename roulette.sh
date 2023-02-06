#!/bin/bash
#rodrigo tavares
#version 2.0
#overhaul of entire script. remade from scratch with options, dynamic variables, modes and logging.

#static variables
#global_budget=1000
#global_wager=10
#global_turns=1000
global_logfile="roulette_logs/roulette_$(date +%Y-%m-%d_%H%M%S).log"
global_delimiter="-"
source ./roulette_perfTest.sh



if [[ ! -d roulette_logs ]]
then
    mkdir roulette_logs
	echo "$global_delimiter" >> $global_logfile
    echo "Info: Logs Directory does not exist. Creating it..." >> $global_logfile
else
	echo "$global_delimiter" >> $global_logfile
	echo "Info: Logs Directory exists already." >> $global_logfile
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
echo "Chosen Values:" >> $global_logfile
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
	echo "Performance Test done. Resuming..." >> $global_logfile
else
	echo "Performance Test not done. Resuming..." >> $global_logfile
	global_perfTestDone=0
fi

if [[ $global_turns -gt 10000 ]]
then
	echo -e "Hinweis:\nDu hast mehr als 10'000 Spiele ausgewählt.\nEs kann länger dauern bis das Programm fertig ist!"
	#add estimated time
	if [[ $global_perfTestDone -eq 1 ]]
	then
		echo -e "\nEs wurde ein Performance Test durchgeführt."
		global_perfEta=$(
			awk "BEGIN { print ($global_turns/$perf_betsPerSec) }"
		)
		echo -e "Geschätzte Dauer der Durchführung dieses Programmes: ${global_perfEta}s"
		echo -e "ETA: ${global_perfEta}s" >> $global_logfile
	else
	 	echo -e "Es wurde kein Performance Test durchgeführt."
	fi
else
	echo -e "Less than 10000 Turns selected. Proceed allowed." >> $global_logfile

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
	echo "Mode chosen: $main_mode" >> $global_logfile
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
		#write log
		#echo "Gewinnerzahl: $solo_winning" >> $global_logfile

		if [[ $solo_winning = $solo_choice ]]
		then
			
			#add winnings
			let solo_budget=solo_budget+$((global_wager * 35))
			#increase won counter to display at end
			let solo_betsWon=solo_betsWon+1
			#write log
			echo "Turn $solo_betsTotal" >> $global_logfile
			echo "You Won: $((global_wager * 35))" >> $global_logfile
			echo "Current Balance: $solo_budget" >> $global_logfile
			echo "$global_delimiter" >> $global_logfile

		#if budget reaches 0 stop the game
		else
			if  [[ $solo_budget > 0 ]]
			then
				let solo_budget=solo_budget-global_wager
				#echo "Wager Depleted from Budget" >> $global_logfile
				#echo "Current Balance: $solo_budget" >> $global_logfile
			else
				let solo_budget=solo_budget-0
				echo "You lost all your money after $solo_betsTotal bets." >> $global_logfile
				break
			fi
		fi
		
		#write log
		#echo "$global_delimiter" >> $global_logfile
	done
	#calculate percentage since bash cant do floating arithemetics
	
	solo_betsPrct=$(
		awk "BEGIN {print (100/$solo_betsTotal)*$solo_betsWon}"
	)
	solo_runtimeEnd=$(date +%s%N)
	solo_runtimeDiff=$(($solo_runtimeEnd - $solo_runtimeStart))
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
elif [[ $main_mode -eq 2 ]] 
then
	echo "even"

else
	echo "error"
fi