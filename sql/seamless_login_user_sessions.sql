drop table if exists jt.seamless_login_users;
drop table if exists jt.seamless_login_sessions;

select a.applicationid
     , a.bundleid
     , u.userid
     , u.globaluserid
     , u.created
     , g.emailaddress
     , g.username
     , g.seamlesslogintoken
into jt.seamless_login_users
from public.authdb_applications a
join public.authdb_is_users u
on a.applicationid = u.applicationid
join public.ratings_globaluserdetails g
on a.bundleid = g.bundleid
and u.globaluserid = g.globaluserid
where (a.applicationid = '8297E8AB-EEE4-43DC-A37E-5D1A07E527C0'
or a.applicationid = '23BDE4BF-CCB3-4C21-9C04-0F515D826C88'
or a.applicationid = '904434F2-C7C7-4C84-A972-BEE9EF324900'
or a.applicationid = 'F0D34EF9-BA6E-4611-A57B-4C528D8E32A8'
or a.applicationid = 'FF757ECB-56A1-41B1-AC02-5F609C3DB3DA'
or a.applicationid = '85874647-B187-49EF-8A45-E3B5720E1755')
and u.isdisabled = 0
and g.isdisabled = 0;

select *
into jt.seamless_login_sessions
from public.fact_sessions a
join (select distinct deviceid from jt.seamless_login ) b
on lower(a.device_id) = lower(cast(deviceid as varchar))
where upper(a.application_id) = '8297E8AB-EEE4-43DC-A37E-5D1A07E527C0'
or upper(a.application_id) = '23BDE4BF-CCB3-4C21-9C04-0F515D826C88'
or upper(a.application_id) = '904434F2-C7C7-4C84-A972-BEE9EF324900'
or upper(a.application_id) = 'F0D34EF9-BA6E-4611-A57B-4C528D8E32A8'
or upper(a.application_id) = 'FF757ECB-56A1-41B1-AC02-5F609C3DB3DA'
or upper(a.application_id) = '85874647-B187-49EF-8A45-E3B5720E1755';
