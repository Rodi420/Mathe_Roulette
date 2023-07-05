#!/bin/bash
#rodrigo tavares
#version 2.7.1
#overhaul of entire script. remade from scratch with options, dynamic variables, modes and logging.

#static variables
#global_budget=1000
#global_wager=10
#global_turns=1000
source ./roulette_perfTest.sh
source ./roulette_func.sh

global_logfile="roulette_logs/roulette_$(date +%Y-%m-%d_%H%M%S).log"
perf_logfile="roulette_logs/roulette_perfTest_$(date +%Y-%m-%d_%H%M%S).log"
global_delimiter="-"



#make log directory if it doesnt exist
if [[ ! -d roulette_logs ]]
then
    mkdir roulette_logs
	echo "$global_delimiter" >> "$global_logfile"
    echo "info: logs directory does not exist. creating it..." >> "$global_logfile"
#if it exists write to log
else
	echo "$global_delimiter" >> "$global_logfile"
	echo "info: logs directory exists already." >> "$global_logfile"
fi

#start
clear
echo -e "Willkommen bei Roulette. Definiere deine Standardwerte:"

#define variables
read -r -p "Dein Budget: " global_budget
read -r -p "Dein Einsatz pro Spiel: " global_wager
read -r -p "Wie viel mal willst du spielen? " global_turns
global_budgetOri=$global_budget

#write log
{
echo "$global_delimiter"
echo "chosen values:" 
echo "global_budget = $global_budget" 
echo "global_wager = $global_wager" 
echo "global_turns = $global_turns"
echo "$global_delimiter" 
} >> "$global_logfile"
clear

#performance test
echo -e "Willst du einen Performance Test durchführen?\n1. Ja\n2. Nein"
read -r -p "Eingabe: " global_perfTest

if [[ $global_perfTest -eq 1 ]]
then
	#do perf test
	func_perfTest
	global_perfTestDone=1
	echo "performance Test done. Resuming..." >> "$global_logfile"
else
	echo "performance Test not done. Resuming..." >> "$global_logfile"
	#this variable value is called nowhere**
	global_perfTestDone=0
fi

if [[ $global_turns -gt 10000 ]]
then
	echo -e "Hinweis:\nDu hast mehr als 10'000 Spiele ausgewählt.\nEs kann länger dauern bis das Programm fertig ist!"
	echo -e "more than 10000 Turns selected. Proceed with caution." >> "$global_logfile"
else
	echo -e "less than 10000 Turns selected. Proceed allowed." >> "$global_logfile"
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
read -r -p "Eingabe: " main_mode

global_betsWon=0
global_betsTotal=0
global_runtimeStart=$(date +%s%N)
if [[ $main_mode -eq 1 ]]
then
	
	#take input
	echo ""
	read -p "Auf welche Zahl willst du wetten? " global_choice


	#write log
	echo "mode chosen: $main_mode" >> $global_logfile
	echo "global_budget = $global_budget" >> $global_logfile
	echo "$global_delimiter" >> $global_logfile
	
	#play the game
	func_rouletteLoop

	#end game
	func_rouletteEnd
elif [[ $main_mode -eq 2 ]] 
then

	echo "mode chosen: $main_mode" >> $global_logfile
	echo "global_budget = $global_budget" >> $global_logfile
	echo "$global_delimiter" >> $global_logfile
	global_choice=$(( 36 % 2 ))
	#play the game
	func_rouletteLoop

	#end game
	func_rouletteEnd

else
	echo "error"
fi