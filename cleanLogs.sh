#!/bin/bash

#Quick script to clean up experiment logs
#usage: ./cleanLogs.sh [mosquitto | mosca | ponte]?

rm multiLogs/*
rm pubLogs/*
rm subLogs/*

if [ "$#" -eq 1 ]; then
	if [[ "$1" == "mosquitto" ]]; then
		rm serverLogs/mosquitto_output.txt
	elif [[ "$1" == "mosca" ]]; then
		rm serverLogs/mosca_output.txt
	elif [[ "$1" == "ponte" ]]; then
		rm serverLogs/ponte_output.txt
	fi
fi
