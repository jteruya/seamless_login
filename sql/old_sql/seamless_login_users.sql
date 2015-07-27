select a.applicationid
     , a.bundleid
     , u.userid
     , u.globaluserid
     , u.created
     , g.emailaddress
     , g.username
     , g.seamlesslogintoken
from authdb.dbo.applications a
join authdb.dbo.is_users u
on a.applicationid = u.applicationid
join ratings.dbo.globaluserdetails g
on a.bundleid = g.bundleid
and u.globaluserid = g.globaluserid
where (a.applicationid = '8297E8AB-EEE4-43DC-A37E-5D1A07E527C0'
or a.applicationid = '23BDE4BF-CCB3-4C21-9C04-0F515D826C88'
or a.applicationid = '904434F2-C7C7-4C84-A972-BEE9EF324900'
or a.applicationid = 'F0D34EF9-BA6E-4611-A57B-4C528D8E32A8'
or a.applicationid = 'FF757ECB-56A1-41B1-AC02-5F609C3DB3DA')
and u.isdisabled = 0
and g.isdisabled = 0;
