#!/usr/bin/env bash

# Use this script to pull just the URLs out of an apache log file
# Useful to replay traffic against test servers

#Target servers to get logs from
servers=("server1" "server2")

#We need to get a few dates. We are looking for the 24 hour period before today ("yesterday"), 
#so we have to do a little bit of cyphering to get it sorted out. Note, there are 86400 seconds in 24 hours.
#This normally works. Sometimes it's a wee bit off.
unix_date=`date +"%s"`
start_date_unix=$(($unix_date - 86400)) 
start_date=`date -d @${start_date_unix} +%d`
end_date_unix=$(($start_date_unix - 86400)) 
end_date=`date -d @${end_date_unix} +%d`
start_month=`date -d @${unix_date} +%b`
end_month=`date -d @${end_date_unix} +%b`
sed_string="${start_date}\/${start_month}/,/${end_date}\/${end_month}"
echo $sed_string
#sometimes we need to set the sed_string by hand
#sed_string="31\/May/,/30\/May"


#cleanup - Delete old files
rm *.txt
rm *.log

for server in ${servers[@]}
do
	#tested awk to see if it could handle leap year. it could not. it's also much slower then sed

	#       awk '/${sed_string}/' /path/to/logstash/${server}/apache2/access.log >> ${server}_access.log
	#       awk '/${sed_string}/' /path/to/logstash/${server}/apache2/access.log.1 >> ${server}_access.log
	#       awk '/${sed_string}/' /path/to/logstash/${server}/apache2/ssl_access.log >> ${server}_access.log
	#       awk '/${sed_string}/' /path/to/logstash/${server}/apache2/ssl_access.log.1 >> ${server}_access.log


	# here we are getting the last two log files (in case there was a log roll in the last 24 hours)
	# we then read them into a single access and ssl access log prepended with the server name
	sed -n "/${sed_string}/p" /path/to/logstash/${server}/apache2/access.log >> ${server}_access.log
	sed -n "/${sed_string}/p" /path/to/logstash/${server}/apache2/access.log.1 >> ${server}_access.log
	sed -n "/${sed_string}/p" /path/to/logstash/${server}/apache2/ssl_access.log >> ${server}_ssl_access.log
	sed -n "/${sed_string}/p" /path/to/logstash/${server}/apache2/ssl_access.log.1 >> ${server}_ssl_access.log

done

#make a big file out of all of the little ones
cat *.log > big_list.txt

#Breakdown of what we are doing:
#cat big_list.txt - Read the file
#| tr -d - | cut -d\" -f2 Grab the correct columns
#| sed 's/GET //' | sed 's/ HTTP\/1.1//' | grep -v "POST" Look for gets that are not posts
#| grep -v "zip"| grep -v "\/pulse" | grep -v "curl" You can add things like this to remove specific items or urls. 
#For example here we are removing zip files, curl and the path /pulse
#| grep -v '^$' >list.txt Finish up


cat big_list.txt | tr -d - | cut -d\" -f2 | sed 's/GET //' | sed 's/ HTTP\/1.1//' | grep -v "POST" | grep -v "zip"| grep -v "\/pulse" | grep -v "curl" | grep -v '^$' >list.txt

#Split out additonal files like these examples to build files that contain all "nav" and all not "nav" errors
cat big_list.txt |grep '"\ 50[0-9]\ ' |grep -v "zip"| grep -v "\/pulse" | grep -v "curl" | grep -v '^$'  | grep  -v "foo" > not_foo_errors.txt
cat big_list.txt |grep '"\ 50[0-9]\ ' |grep -v "zip"| grep -v "\/pulse" | grep -v "curl" | grep -v '^$' | grep "foo" > foo_errors.txt

#You can also get raw numbers out of each app's log files like this:
apps=("app1" "app2" "app3")

for app in ${apps[@]}
do
	grep "\/${app}\/" list.txt > ${app}_list.txt
	echo `wc -l ${app}_list.txt`
done
echo `wc -l not_foo_errors.txt`
echo `wc -l foo_errors.txt`

# let's build a csv file for later consumption by a database

if [ ! -e report.csv ]
 then
   touch report.csv
   printf "Date of Run,">>report.csv
   for app in ${apps[@]}
       do
        printf "${app},">>report.csv
       done
   echo -e ",Foo Errors,Not Foo Errors">>report.csv
fi
printf "$(date),">>report.csv
for app in ${apps[@]}
	do
         grep "\/${app}\/" list.txt > ${app}_list.txt
         printf `wc -l ${app}_list.txt`>>report.csv
         printf ",">>report.csv
	done
	printf `wc -l not_foo_errors.txt`>>report.csv
	printf ",">>report.csv
	printf `wc -l foo_errors.txt`>>report.csv
	printf ",">>report.csv
echo -e "">>report.csv

#make this usable by the masses

chown -R user:group /path/to/hammer_of_justice/*
chmod -R g+x /path/to/hammer_of_justice/*.sh
chmod -R g+r /path/to/hammer_of_justice/*

