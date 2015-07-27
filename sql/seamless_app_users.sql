drop table if exists jt.seamless_login_first_session_info;
drop table if exists jt.seamless_login_first_session_info_users;
drop table if exists jt.seamless_login_event_users;

/* seamless_login_first_session_info */
 
select distinct a.application_id
     , a.user_id
     , a.first_session_date
     , b.device_id
     , b.app_type_id
into jt.seamless_login_first_session_info
from (select application_id
           , user_id
           , min(start_date) as first_session_date
      from fact_sessions where metrics_type_id = 1
      and (lower(application_id) = '3e92f6b3-59a3-4078-9be0-42dd25c8ccc2'
      or lower(application_id) = '8297e8ab-eee4-43dc-a37e-5d1a07e527c0'
      or lower(application_id) = '23bde4bf-ccb3-4c21-9c04-0f515d826c88'
      or lower(application_id) = '904434f2-c7c7-4c84-a972-bee9ef324900'
      or lower(application_id) = 'f0d34ef9-ba6e-4611-a57b-4c528d8e32a8'
      or lower(application_id) = 'ff757ecb-56a1-41b1-ac02-5f609c3db3da'
      or lower(application_id) = '85874647-b187-49ef-8a45-e3b5720e1755')
      group by 1,2) a
join (select application_id
           , user_id
           , device_id
           , app_type_id
           , start_date
      from fact_sessions where metrics_type_id = 1
      and (lower(application_id) = '3e92f6b3-59a3-4078-9be0-42dd25c8ccc2'
      or lower(application_id) = '8297e8ab-eee4-43dc-a37e-5d1a07e527c0'
      or lower(application_id) = '23bde4bf-ccb3-4c21-9c04-0f515d826c88'
      or lower(application_id) = '904434f2-c7c7-4c84-a972-bee9ef324900'
      or lower(application_id) = 'f0d34ef9-ba6e-4611-a57b-4c528d8e32a8'
      or lower(application_id) = 'ff757ecb-56a1-41b1-ac02-5f609c3db3da'
      or lower(application_id) = '85874647-b187-49ef-8a45-e3b5720e1755')) b
on a.application_id = b.application_id and a.user_id = b.user_id and a.first_session_date = b.start_date;

/* seamless_login_first_session_info_users */ 

select s.application_id
     , s.user_id
     , e.name
     , e.startdate
     , e.enddate
     , u.globaluserid
     , s.app_type_id
     , s.device_id
     , a.bundleid
     , g.emailaddress
     , g.firstname
     , g.username
     , g.phone
into jt.seamless_login_first_session_info_users
from (select distinct application_id
           , user_id
           , app_type_id
           , device_id
      from jt.seamless_login_first_session_info) s
join jt.tm_is_users u
on s.user_id = u.userid
join jt.tm_applications a
on s.application_id = a.applicationid::varchar
join jt.tm_globaluserdetails g
on g.globaluserid = u.globaluserid and g.bundleid = a.bundleid
join jt.tm_eventcubesummary e
on s.application_id = e.applicationid::varchar;

/* jt.seamless_login_event_users */

select distinct u.application_id
           , e.name
           , e.startdate
           , e.enddate
           , u.user_id
           , u.globaluserid
           , u.emailaddress
           , f.recipientemail
           , f.clicked_bnc_flag
           , u.app_type_id
           , case
               when f.clicked_bnc_flag = true and u.app_type_id = 3 and f.clicked_bnc_clientos = 'Android' then true
               when f.clicked_bnc_flag = true and u.app_type_id = 1 and f.clicked_bnc_devicetype = 'mobile' and f.clicked_bnc_clientos = 'iOS' then true
               when f.clicked_bnc_flag = true and u.app_type_id = 2 and f.clicked_bnc_devicetype = 'tablet' and f.clicked_bnc_clientos = 'iOS' then true
               else null
             end as clicked_bnc_device_match_flag
      into jt.seamless_login_event_users
      from jt.seamless_login_first_session_info_users u
      left join (select distinct applicationid 
                      , recipientemail
                      , clicked_bnc_flag
                      , clicked_bnc_clientos
                      , clicked_bnc_devicetype
                 from jt.seamless_fact_analysis 
                 where clicked_bnc_flag = true
                 and clicked_bnc_devicetype = 'mobile') f
      on u.emailaddress = f.recipientemail and u.application_id = f.applicationid::varchar
      join jt.tm_eventcubesummary e
      on u.application_id = e.applicationid::varchar;


/* Connect Email Funnel with 1st Session Device Type */

select application_id
     , name
     , startdate
     , enddate
     , count(*) as total_app_users
     --, count(case when clicked_flag is null then 1 else null end) as seamless_users_not_in_funnel
     --, count(case when clicked_flag = true then 1 else null end) as total_users_logged_in_with_seamless_users_in_funnel
     --, count(case when clicked_flag = false and emailaddress is not null then 1 else null end) as seamless_users_no_click_in_funnel
     --, count(case when clicked_flag is null and emailaddress is null then 1 else null end) as seamless_users_no_email_address
     , count(case when clicked_bnc_flag = true then 1 else null end) as app_user_clicked_bnc
     , count(case when clicked_bnc_device_match_flag = true then 1 else null end) as seamless_user
     , count(case when clicked_bnc_device_match_flag = true and app_type_id in (1,2) then 1 else null end) as seamless_ios_user
     , count(case when clicked_bnc_device_match_flag = true and app_type_id in (3) then 1 else null end) as seamless_android_user
from jt.seamless_login_event_users
group by 1,2,3,4
order by 3,4;
