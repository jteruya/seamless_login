  set schema 'jt'
  ;

  drop table if exists seamless_login_users;

  create table seamless_login_users (
        applicationid uuid
      , bundleid uuid
      , userid int
      , globaluserid uuid
      , created timestamp
      , emailaddress varchar
      , username varchar
      , seamlesslogintoken varchar);

  copy seamless_login_users 
  from '/home/jteruya/seamless_login/sql/clean_seamless_login_users.csv'
  delimiter ','
  csv
  ;
