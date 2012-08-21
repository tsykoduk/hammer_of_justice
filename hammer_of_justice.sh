#!/usr/bin/env bash

# read in the file handed to the script and fire off a bunch of reqests against a target server 5 times.
server="test.example.com" #target
domain="example.com"
targets=`cat ${1}`

echo "One!!"

for this_target in $targets
do
	url="http://$server$this_target"
	curl -k "$url" &> /dev/null
done

echo "Two!!"

for this_target in $targets
do
	url="http://$server$this_target"
	curl -k "$url" &> /dev/null
done

echo "Tres"

for this_target in $targets
do
	url="http://$server$this_target"
	curl -k "$url" &> /dev/null
done

echo "Shi"

for this_target in $targets
do
	url="http://$server$this_target"
	curl -k "$url" &> /dev/null
done

echo "party, number five"

for this_target in $targets
do
	url="http://$server/$this_target"
	curl -k "$url" &> /dev/null
done
