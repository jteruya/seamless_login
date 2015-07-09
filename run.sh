#!/bin/sh

# Pull Seamlessloginsuccess metric records from ES into Alfred
python es_pull.py $1 $2
python parse_data/parse_es_logs.py
python load_data/load_parsed_data.py

#python /home/jteruya/tools/get_csv.py /home/jteruya/seamless_login/sql/seamless_login_users.sql
#python /home/jteruya/tools/get_csv.py /home/jteruya/seamless_login/sql/seamless_login_sessions.sql

#sed 's/,None/,/g' sql/seamless_login_users.csv | tail -n +2 > sql/clean_seamless_login_users.csv
#sed 's/,None/,/g' sql/seamless_login_sessions.csv | tail -n +2 > sql/clean_seamless_login_sessions.csv

#psql -h 10.223.176.157 -p 5432 dev jteruya -f "sql/batman_push_seamless_login_users.sql"
#psql -h 10.223.176.157 -p 5432 dev jteruya -f "sql/batman_push_seamless_login_sessions.sql"

# Create Email Funnel for Seamless Login Events
psql -h 10.208.97.116 -p 5432 etl analytics -f "sql/seamless_login_email_funnel.sql"

# Create Session and User Tables for Seamless Login Events
#psql -h 10.208.97.116 -p 5432 etl analytics -f "sql/seamless_login_user_sessions.sql"
