
  set schema 'jt'
  ;

  \set table seamless_login 
  drop table if exists :table
  ;
  create table :table
  ( timestamp timestamp,
    deviceid uuid,
    deviceos text,
    mmminfo text,
    applicationid uuid,
    globaluserid uuid,
    apptypeid int
  )
  ;

  