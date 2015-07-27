drop table if exists jt.seamless_sessions_tracker;
drop table if exists jt.seamless_sessions_length_tracker;

/* seamless_sessions_tracker */

select a.application_id
     , a.name
     , a.startdate
     , a.enddate
     , a.user_id
     , a.globaluserid
     , a.emailaddress
     , case
         when clicked_bnc_device_match_flag is null and app_type_id in (1,2) then 'regular_ios_user'
         when clicked_bnc_device_match_flag is null and app_type_id in (3) then 'regular_android_user'
         when clicked_bnc_device_match_flag = true and app_type_id in (1,2) then 'seamless_ios_user'
         when clicked_bnc_device_match_flag = true and app_type_id in (3) then 'seamless_android_user'
       end as user_type
     , b.session_cnt
into jt.seamless_sessions_tracker
from jt.seamless_login_event_users a
join (select application_id
           , user_id
           , count(*) as session_cnt
      from fact_sessions where metrics_type_id = 1
      and (lower(application_id) = '3e92f6b3-59a3-4078-9be0-42dd25c8ccc2'
      or lower(application_id) = '8297e8ab-eee4-43dc-a37e-5d1a07e527c0'
      or lower(application_id) = '23bde4bf-ccb3-4c21-9c04-0f515d826c88'
      or lower(application_id) = '904434f2-c7c7-4c84-a972-bee9ef324900'
      or lower(application_id) = 'f0d34ef9-ba6e-4611-a57b-4c528d8e32a8'
      or lower(application_id) = 'ff757ecb-56a1-41b1-ac02-5f609c3db3da'
      or lower(application_id) = '85874647-b187-49ef-8a45-e3b5720e1755') 
      group by 1,2) b
on a.application_id = b.application_id and a.user_id = b.user_id;

/* Session Counts */

select a.application_id
     , a.name
     , a.startdate
     , a.enddate
     , a.user_type_cnt
     , a.average_session_cnt
     , b.median_session_cnt
     , a.regular_user_cnt
     , a.average_regular_session_cnt
     , c.median_session_cnt as median_regular_session_cnt
     , a.seamless_user_cnt
     , a.average_seamless_session_cnt
     , d.median_session_cnt as median_seamless_session_cnt
     , a.regular_ios_user_cnt
     , a.average_ios_regular_session_cnt
     , e.median_session_cnt as median_ios_regular_session_cnt
     , a.regular_android_user_cnt
     , a.average_android_regular_session_cnt
     , f.median_session_cnt as median_android_regular_session_cnt
     , a.seamless_ios_user_cnt
     , a.average_ios_seamless_session_cnt
     , g.median_session_cnt as median_ios_seamless_session_cnt
     , a.seamless_android_user_cnt
     , a.average_android_seamless_session_cnt
     , h.median_session_cnt as median_android_seamless_session_cnt
from (select application_id
           , name
           , startdate
           , enddate
           , count(*) as user_type_cnt
           , avg(session_cnt) as average_session_cnt
           , count(case when user_type like 'regular%' then 1 else null end) as regular_user_cnt
           , avg(case when user_type like 'regular%' then session_cnt else null end) as average_regular_session_cnt
           , count(case when user_type like 'seamless%' then 1 else null end) as seamless_user_cnt
           , avg(case when user_type like 'seamless%' then session_cnt else null end) as average_seamless_session_cnt
           , count(case when user_type like 'regular_ios_user' then 1 else null end) as regular_ios_user_cnt
           , avg(case when user_type like 'regular_ios_user' then session_cnt else null end) as average_ios_regular_session_cnt
           , count(case when user_type like 'regular_android_user' then 1 else null end) as regular_android_user_cnt
           , avg(case when user_type like 'regular_android_user' then session_cnt else null end) as average_android_regular_session_cnt
           , count(case when user_type like 'seamless_ios_user' then 1 else null end) as seamless_ios_user_cnt
           , avg(case when user_type like 'seamless_ios_user' then session_cnt else null end) as average_ios_seamless_session_cnt
           , count(case when user_type like 'seamless_android_user' then 1 else null end) as seamless_android_user_cnt
           , avg(case when user_type like 'seamless_android_user' then session_cnt else null end) as average_android_seamless_session_cnt
      from jt.seamless_sessions_tracker
      group by 1,2,3,4) a
join (select application_id
           , percentile_cont(0.5) within group (order by session_cnt) as median_session_cnt
      from jt.seamless_sessions_tracker
      group by 1) b
on a.application_id = b.application_id
join (select application_id
           , percentile_cont(0.5) within group (order by session_cnt) as median_session_cnt
      from jt.seamless_sessions_tracker
      where user_type like 'regular%'
      group by 1) c
on a.application_id = c.application_id
join (select application_id
           , percentile_cont(0.5) within group (order by session_cnt) as median_session_cnt
      from jt.seamless_sessions_tracker
      where user_type like 'seamless%'
      group by 1) d
on a.application_id = d.application_id
join (select application_id
           , percentile_cont(0.5) within group (order by session_cnt) as median_session_cnt
      from jt.seamless_sessions_tracker
      where user_type like 'regular_ios_user'
      group by 1) e
on a.application_id = e.application_id
join (select application_id
           , percentile_cont(0.5) within group (order by session_cnt) as median_session_cnt
      from jt.seamless_sessions_tracker
      where user_type like 'regular_android_user'
      group by 1) f
on a.application_id = f.application_id
join (select application_id
           , percentile_cont(0.5) within group (order by session_cnt) as median_session_cnt
      from jt.seamless_sessions_tracker
      where user_type like 'seamless_ios_user'
      group by 1) g
on a.application_id = g.application_id
join (select application_id
           , percentile_cont(0.5) within group (order by session_cnt) as median_session_cnt
      from jt.seamless_sessions_tracker
      where user_type like 'seamless_android_user'
      group by 1) h
on a.application_id = h.application_id;

/* seamless_sessions_length_tracker */

select a.application_id
     , a.name
     , a.startdate
     , a.enddate
     , a.user_id
     , a.globaluserid
     , a.emailaddress
     , case
         when clicked_bnc_device_match_flag is null and app_type_id in (1,2) then 'regular_ios_user'
         when clicked_bnc_device_match_flag is null and app_type_id in (3) then 'regular_android_user'
         when clicked_bnc_device_match_flag = true and app_type_id in (1,2) then 'seamless_ios_user'
         when clicked_bnc_device_match_flag = true and app_type_id in (3) then 'seamless_android_user'
       end as user_type
     , b.duration
into jt.seamless_sessions_length_tracker
from jt.seamless_login_event_users a
join (select applicationid
                , userid
                , enddate - startdate as duration
           from jt.tm_sessions
           where (applicationid = '3e92f6b3-59a3-4078-9be0-42dd25c8ccc2'
           or applicationid = '8297e8ab-eee4-43dc-a37e-5d1a07e527c0'
           or applicationid = '23bde4bf-ccb3-4c21-9c04-0f515d826c88'
           or applicationid = '904434f2-c7c7-4c84-a972-bee9ef324900'
           or applicationid = 'f0d34ef9-ba6e-4611-a57b-4c528d8e32a8'
           or applicationid = 'ff757ecb-56a1-41b1-ac02-5f609c3db3da'
           or applicationid = '85874647-b187-49ef-8a45-e3b5720e1755')
           and apptypeid < 4
           and enddate is not null
           and enddate >= startdate) b
on a.application_id = b.applicationid::varchar and a.user_id = b.userid;

/* Session Lengths */

select a.application_id
     , a.name
     , a.startdate
     , a.enddate
     , a.average_session_duration
     , b.median_session_duration
     , a.average_regular_session_duration
     , c.median_session_duration as median_regular_session_duration
     , a.average_seamless_session_duration
     , d.median_session_duration as median_seamless_session_duration
     , a.average_ios_regular_session_duration
     , e.median_session_duration as median_ios_regular_session_duration
     , a.average_android_regular_session_duration
     , f.median_session_duration as median_android_regular_session_duration
     , a.average_ios_seamless_session_duration
     , g.median_session_duration as median_ios_seamless_session_duration
     , a.average_android_seamless_session_duration
     , h.median_session_duration as median_android_seamless_session_duration
from (select application_id
           , name
           , startdate
           , enddate
           , avg(duration) as average_session_duration
           , avg(case when user_type like 'regular%' then duration else null end) as average_regular_session_duration
           , avg(case when user_type like 'seamless%' then duration else null end) as average_seamless_session_duration
           , avg(case when user_type like 'regular_ios_user' then duration else null end) as average_ios_regular_session_duration
           , avg(case when user_type like 'regular_android_user' then duration else null end) as average_android_regular_session_duration
           , avg(case when user_type like 'seamless_ios_user' then duration else null end) as average_ios_seamless_session_duration
           , avg(case when user_type like 'seamless_android_user' then duration else null end) as average_android_seamless_session_duration
      from jt.seamless_sessions_length_tracker
      group by 1,2,3,4) a
join (select application_id
           , percentile_cont(0.5) within group (order by duration) as median_session_duration
      from jt.seamless_sessions_length_tracker
      group by 1) b
on a.application_id = b.application_id
join (select application_id
           , percentile_cont(0.5) within group (order by duration) as median_session_duration
      from jt.seamless_sessions_length_tracker
      where user_type like 'regular%'
      group by 1) c
on a.application_id = c.application_id
join (select application_id
           , percentile_cont(0.5) within group (order by duration) as median_session_duration
      from jt.seamless_sessions_length_tracker
      where user_type like 'seamless%'
      group by 1) d
on a.application_id = d.application_id
join (select application_id
           , percentile_cont(0.5) within group (order by duration) as median_session_duration
      from jt.seamless_sessions_length_tracker
      where user_type like 'regular_ios_user'
      group by 1) e
on a.application_id = e.application_id
join (select application_id
           , percentile_cont(0.5) within group (order by duration) as median_session_duration
      from jt.seamless_sessions_length_tracker
      where user_type like 'regular_android_user'
      group by 1) f
on a.application_id = f.application_id
join (select application_id
           , percentile_cont(0.5) within group (order by duration) as median_session_duration
      from jt.seamless_sessions_length_tracker
      where user_type like 'seamless_ios_user'
      group by 1) g
on a.application_id = g.application_id
join (select application_id
           , percentile_cont(0.5) within group (order by duration) as median_session_duration
      from jt.seamless_sessions_length_tracker
      where user_type like 'seamless_android_user'
      group by 1) h
on a.application_id = h.application_id;
