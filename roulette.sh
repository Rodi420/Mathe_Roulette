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
#global_delimiter2="_"


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
if [[ $global_turns -gt 10000 ]]
then
	echo -e "Hinweis:\nDu hast mehr als 10'000 Spiele ausgewählt.\nEs kann mehrere Minuten dauern bis das Programm fertig ist!"

else
	echo -e "Less than 10000 Turns selected. Proceed allowed." >> $global_logfile

fi


echo -e "\nWähle ein Spielmodus\n1. Einzelnummern\n2. Even\n3. Odd\n4. Row"
read -n 1 -p "Eingabe: " main_mode

if [[ $main_mode -eq 1 ]]
then

	#take input
	echo ""
	read -p "Auf welche Zahl willst du wetten? " solo_choice

	#mode speficic variables
	solo_budget=$global_budget
	solo_betsWon=0
	solo_betsTotal=0
	solo_runtimeStart=$(date +%s)
	#write log
	echo "Mode chosen: $main_mode" >> $global_logfile
	echo "solo_budget = $solo_budget" >> $global_logfile
	echo "$global_delimiter" >> $global_logfile
	
	while [[ $global_turns>0 ]] 
	do
		#get winning number
		solo_winning=$(( $RANDOM % 36))
		#write log
		echo "Gewinnerzahl: $solo_winning" >> $global_logfile

		if [[ $solo_winning = $solo_choice ]]
		then
			
			#add winnings
			let solo_budget=solo_budget+$((global_wager * 35))
			#increase won counter to display at end
			let solo_betsWon=solo_betsWon+1
			echo "You Won: $((global_wager * 35))" >> $global_logfile
			echo "Current Balance: $solo_budget" >> $global_logfile
			#remove wager from budget
			#let global_budget=global_budget-global_wager
			#echo "Wager Depleted from Budget" >> $global_logfile

		#if budget reaches 0 stop the game
		else
			if  [[ $solo_budget > 0 ]]
			then
				let solo_budget=solo_budget-global_wager
				echo "Wager Depleted from Budget" >> $global_logfile
				echo "Current Balance: $solo_budget" >> $global_logfile
			else
				let solo_budget=solo_budget-0
				echo "You lost all your money." >> $global_logfile
				break
			fi
		fi
		#reduce turns by 1
		let global_turns=global_turns-1
		#increase total bets counter to display at end
		let solo_betsTotal=solo_betsTotal+1
		#write log
		echo "$global_delimiter" >> $global_logfile
	done
	#calculate percentage since bash cant do floating arithemetics
	
	solo_betsPrct=$(
		awk "BEGIN {print (100/$solo_betsTotal)*$solo_betsWon}"
	)
	solo_runtimeEnd=$(date +%s)
	solo_runtimeDiff=$(($solo_runtimeEnd - $solo_runtimeStart))
	#show results
	echo "Final Balance: $solo_budget"
	echo "Profit Made: $(($solo_budget-$global_budget))"
	echo "You won $solo_betsWon out of $solo_betsTotal bets. (${solo_betsPrct}%)"
	echo "Program finished after ${solo_runtimeDiff}s"
	#write log
	echo "Final Balance: $solo_budget" >> $global_logfile
	echo "Profit Made: $(($solo_budget-$global_budget))" >> $global_logfile
	echo "You won $solo_betsWon out of $solo_betsTotal bets. (${solo_betsPrct}%)" >> $global_logfile
	echo "Program finished after $(($solo_runtimeStart-$solo_runtimeEnd))s" >> $global_logfile
elif [[ $main_mode -eq 2 ]] 
then
	echo "even"

else
	echo "error"
fi