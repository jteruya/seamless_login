
  set schema 'jt'
  ;
  
  \copy seamless_login from '/home/jteruya/seamless_login/parse_data/parsed_data/seamless_login_6_logstash-2015.06.06.csv' delimiter ',' csv;
  