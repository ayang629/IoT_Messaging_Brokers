#!/bin/bash

#Quick script to clean up experiment logs
#usage: ./cleanLogs.sh [mosquitto | mosca | ponte]?

rm multiLogs/*
rm pubLogs/*
rm subLogs/*

if [ "$#" -eq 1 ]; then
	if [[ "$1" == "mosquitto" ]]; then
		rm mosquitto_output.txt
	elif [[ "$1" == "mosca" ]]; then
		rm mosca_output.txt
	elif [[ "$1" == "ponte" ]]; then
		rm ponte_output.txt
	fi
fi
