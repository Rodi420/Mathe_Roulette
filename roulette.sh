#!/bin/bash
# Rodrigo Tavares
# Version 2.9
# Overhaul of entire script. remade from scratch with options, dynamic variables, modes and logging.

# Static variables
#global_budget=1000
#global_wager=10
#global_turns=1000
source ./roulette_perfTest.sh
source ./roulette_func.sh

global_logfile="roulette_logs/roulette_$(date +%Y-%m-%d_%H%M%S).log"
perf_logfile="roulette_logs/roulette_perfTest_$(date +%Y-%m-%d_%H%M%S).log"
global_delimiter="-"



# Make log directory if it doesnt exist
if [[ ! -d roulette_logs ]]; then
    mkdir roulette_logs
	echo "$global_delimiter" >> "$global_logfile"
    echo "info: logs directory does not exist. creating it..." >> "$global_logfile"
# If it exists write to log
else
	echo "$global_delimiter" >> "$global_logfile"
	echo "info: logs directory exists already." >> "$global_logfile"
fi

# Start
clear
printf '%100s\n' | tr ' ' -
echo -e "Willkommen bei Roulette. Definiere deine Standardwerte:"
printf '%100s\n' | tr ' ' -

# Define variables
read -r -p "Dein Budget: " global_budget
read -r -p "Dein Einsatz pro Spiel: " global_wager
read -r -p "Wie viel mal willst du spielen? " global_turns
printf '%100s\n' | tr ' ' -
global_budgetOri=$global_budget

# Write log
{
echo "$global_delimiter"
echo "chosen values:" 
echo "global_budget = $global_budget" 
echo "global_wager = $global_wager" 
echo "global_turns = $global_turns"
echo "$global_delimiter" 
} >> "$global_logfile"
clear


# Choose mode before perf test
printf '%100s\n' | tr ' ' -
echo -e "Wähle ein Spielmodus\n1. Einzelnummern\n2. Gerade Zahlen (Standard)\n3. Ungerade Zahlen\n4. Reihe von Zahlen"
read -r -p "Eingabe: " main_mode

# Ask for performance test
printf '%100s\n' | tr ' ' -
echo -e "Willst du einen Performance Test durchführen?\n1. Ja\n2. Nein (Standard)"
read -r -p "Eingabe: " global_perfTest
printf '%100s\n' | tr ' ' -

# Do perf test
if [[ $global_perfTest -eq 1 ]]; then
	func_perfTest
	global_perfTestDone=1
	echo "performance Test done. Resuming..." >> "$global_logfile"
else
	echo "performance Test not done. Resuming..." >> "$global_logfile"
	# This variable value is called nowhere
	global_perfTestDone=0
fi

# Inform about long processing time
if [[ $global_turns -gt 10000 ]]; then
	#printf '%100s\n' | tr ' ' -
	echo -e "Hinweis:\nDu hast mehr als 10'000 Spiele ausgewählt.\nEs kann länger dauern bis das Programm fertig ist!"
	echo -e "more than 10000 Turns selected. Proceed with caution." >> "$global_logfile"
else
	echo -e "less than 10000 Turns selected. Proceed allowed." >> "$global_logfile"
fi

printf '%100s\n' | tr ' ' -

# Do perf test after mode was chosen
# Performance test was done
if [[ $global_perfTestDone -eq 1 ]]; then
	echo -e "Es wurde ein Performance Test durchgeführt."
	# Calculate eta runtime
	global_perfEta=$(
		awk "BEGIN { print ($global_turns/$perf_betsPerSec) }"
	)
	echo -e "Geschätzte Dauer der Durchführung dieses Programmes: ${global_perfEta}s"
	echo -e "ETA: ${global_perfEta}s" >> "$global_logfile"
else
	echo -e "Es wurde kein Performance Test durchgeführt."
fi

printf '%100s\n' | tr ' ' -
echo -e "Fortfahren?\n1. Ja (Standard)\n2. Nein"
read -r -p "Eingabe: " main_resume
printf '%100s\n' | tr ' ' -

if [[ $main_resume -eq 2 ]]; then
	exit 1
fi

# Write log
{
echo "mode chosen: $main_mode"
echo "$global_delimiter" 
} >> "$global_logfile"

case $main_mode in
	1)
		# Take input
		read -p "Auf welche Zahl willst du wetten? " global_choice
		printf '%100s\n' | tr ' ' -
		# Play the game
		func_rouletteLoop
		# End game
		func_rouletteEnd
		;;
	2)
		# Play the game
		func_rouletteLoop
		# End game
		func_rouletteEnd
		;;
	3)
		# Play the game
		func_rouletteLoop
		# End game
		func_rouletteEnd
		;;	
	4)
		# Take input
		echo -e "Auf welche Reihe willst du wetten?\n1. 1-9 (Standard)\n2. 10-18\n3. 19-27\n4. 28-36"
		read -p "Eingabe: " global_choice

		if [[ $global_choice -eq 2 ]]; then
			global_rowOne=10
			global_rowTwo=18
		elif [[ $global_choice -eq 3 ]]; then
			global_rowOne=19
			global_rowTwo=27
		elif [[ $global_choice -eq 4 ]]; then
			global_rowOne=28
			global_rowTwo=36
		else
			global_rowOne=1
			global_rowTwo=9
		fi

		printf '%100s\n' | tr ' ' -
		# Play the game
		func_rouletteLoop
		# End game
		func_rouletteEnd
		;;	
	*)
		# Standard value option -> run "Even" mode
		main_mode=2
		# Play the game
		func_rouletteLoop
		# End game
		func_rouletteEnd
		;;
esac