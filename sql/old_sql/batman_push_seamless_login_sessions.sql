  set schema 'jt'
  ;

  drop table if exists seamless_login_sessions;

  create table seamless_login_sessions (
        sessionid bigint
      , applicationid uuid
      , deviceid varchar
      , userid int
      , devicetypeid smallint
      , startdate timestamp
      , enddate timestamp
      , apptypeid smallint
      , lastactivitydate timestamp
      , binaryversion varchar
      , deviceosversion varchar
      , mmminfo varchar
      , autoclosed boolean);


  copy seamless_login_sessions 
  from '/home/jteruya/seamless_login/sql/clean_seamless_login_sessions.csv'
  delimiter ','
  csv
  ;
