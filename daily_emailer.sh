#!/usr/bin/env bash

#uses the Hammer of Justice's url importer to create a daily report on by service usage from the day before


email="mail1@example.com,mail2@example.com"

meat=`./apache_url_extractor.sh`

report="Daily Hammer Report for Yesterday! \n\n+=+=+=+=+=+=+=+=+\n\n ${meat} \n\n\n\n\n\n\n\n\n\n"

if [[ -s not_foo_errors.txt ]] ; then
	printf "${report}" | mutt -s "Daily Hammer Report" -a not_foo_errors.txt foo_errors.txt report.csv -- $email
else
	printf "${report}" | mutt -s "Daily Hammer Report" -a report.csv -- $email
fi ;
