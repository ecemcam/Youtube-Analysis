--Create the database 
create database youtube;

--Create Channels table that would hold the statistcis about each channel
create table channels(
	channel_id varchar primary key, 
	channel_name	varchar,
	subscribers		int, 
	views			int, 
	total_videos	int, 
	playlist_id    varchar
)


--Create Videos table that would hold the statistcis about each channel's Videos.
create table videos(
	channel_id	varchar,
	title	varchar,
	publish_date	date, 
	views	int,
	likes	int null,
	comments	int null,
	month     varchar
)


select *from channels;
select *from videos;


--EDA of Youtube Channels

--I see Statistics don't depend on one another the Channel which has less number of videos can have more views, Subscribers and viceversa. 
select *
from channels
order by views desc;

select *
from channels
order by subscribers desc;

select *
from channels
order by total_videos desc;


--Shows Monthly Statisctics of a Channel(Channel_id): Likes, Views and Comments.
select ch.channel_name, vd.month,extract('year' from vd.publish_date) as year,
		sum(vd.views) as Monthly_views, 
		sum(vd.likes) as Monthly_likes, 
		sum(vd.comments) as Monthly_comments
from channels ch 
inner join videos vd using(channel_id)
where ch.channel_id ilike 'UCzd0MT-KhUK1OMk7Ac9DBBQ' 
group by ch.channel_name, extract('month' from vd.publish_date), extract('year' from vd.publish_date),vd.month
order by extract('month' from vd.publish_date) asc;


--Shows annual Statistics of a Channel: Likes, Views and Comments.
with channel_statistics as (
	select ch.channel_name, vd.month,extract('year' from vd.publish_date) as year,
		sum(vd.views) as Monthly_views, 
		sum(vd.likes) as Monthly_likes, 
		sum(vd.comments) as Monthly_comments
	from channels ch 
	inner join videos vd using(channel_id)
	where ch.channel_id ilike 'UCzd0MT-KhUK1OMk7Ac9DBBQ' 
	group by ch.channel_name, extract('month' from vd.publish_date), extract('year' from vd.publish_date),vd.month
	order by extract('month' from vd.publish_date) asc
)
select channel_name, year, 
	sum(Monthly_views) as annual_views,
	sum(Monthly_likes) as annual_likes,
	sum(Monthly_comments) as annual_comments 
from channel_statistics
group by channel_name, year
order by year asc;


--Growth Rate of Views of a Channel.

select channel_name, month, year,
	Monthly_views as current_month_views,
	lag(Monthly_views, 1) over (partition by year order by month_num asc) as previous_month_views,
	round((100.0 * ( Monthly_views - (lag(Monthly_views, 1) over (partition by year order by month_num asc)) )) 
	/ (lag(Monthly_views, 1) over (partition by year order by month_num asc)), 1) as Mothly_Views_Growth
from (
	select ch.channel_name, vd.month as month, extract('month' from vd.publish_date) as month_num, extract('year' from vd.publish_date) as year, 
		sum(vd.views) as Monthly_views, 
		sum(vd.likes) as Monthly_likes, 
		sum(vd.comments) as Monthly_comments
	from channels ch inner join videos vd using(channel_id)
	where ch.channel_id ilike 'UCzd0MT-KhUK1OMk7Ac9DBBQ'
	group by ch.channel_name, extract('month' from vd.publish_date), extract('year' from vd.publish_date), vd.month
	order by extract('month' from vd.publish_date) asc
);


--Growth Rate of Likes of a Channel.
select channel_name, month, year,
	Monthly_likes as current_month_likes,
	lag(Monthly_likes, 1) over (partition by year order by month_num asc) as previous_month_likes,

--Using Case Statement to prevent division by zero casue, Likes and Comments Column can have null values. 
	case 

	when (lag(Monthly_likes, 1) over (partition by year order by month_num asc)) = 0 then null
	
	else 
	round((100.0 *  ( Monthly_likes - (lag(Monthly_likes, 1) over (partition by year order by month_num asc)) )) 
	/ (lag(Monthly_likes, 1) over (partition by year order by month_num asc)), 1) 
	
	end as Mothly_Likes_Growth
from (
	select ch.channel_name, vd.month as month, extract('month' from vd.publish_date) as month_num, extract('year' from vd.publish_date) as year, 
		sum(vd.views) as Monthly_views, 
		sum(vd.likes) as Monthly_likes, 
		sum(vd.comments) as Monthly_comments
	from channels ch inner join videos vd using(channel_id)
	where ch.channel_id ilike 'UCzd0MT-KhUK1OMk7Ac9DBBQ'
	group by ch.channel_name, extract('month' from vd.publish_date), extract('year' from vd.publish_date), vd.month
	order by extract('month' from vd.publish_date) asc
);



--Growth Rate of Comments of a Channel.
select channel_name, month, year,
	Monthly_comments as current_month_comments,
	lag(Monthly_comments, 1) over (partition by year order by month_num asc) as previous_month_comments,

--Using Case Statement to prevent division by zero casue, Likes and Comments Column can have null values. 
	case 

	when (lag(Monthly_comments, 1) over (partition by year order by month_num asc)) = 0 then null
	
	else 
	round((100.0 * ( Monthly_comments - (lag(Monthly_comments, 1) over (partition by year order by month_num asc)) )) 
	/ (lag(Monthly_comments, 1) over (partition by year order by month_num asc)), 1) 
	
	end as Mothly_Comments_Growth
from (
	select ch.channel_name, vd.month as month, extract('month' from vd.publish_date) as month_num, extract('year' from vd.publish_date) as year, 
		sum(vd.views) as Monthly_views, 
		sum(vd.likes) as Monthly_likes, 
		sum(vd.comments) as Monthly_comments
	from channels ch inner join videos vd using(channel_id)
	where ch.channel_id ilike 'UCzd0MT-KhUK1OMk7Ac9DBBQ'
	group by ch.channel_name, extract('month' from vd.publish_date), extract('year' from vd.publish_date), vd.month
	order by extract('month' from vd.publish_date) asc
);


--Top 5 Mostly Viewed Vidoes of a particular channel.
select ch.channel_name, vd.title, vd.views
from channels ch 
inner join videos vd using(channel_id)
where ch.channel_id ilike 'UCO5QSoES5yn2Dw7YixDYT5Q' 
group by ch.channel_name,vd.title,vd.views
order by vd.views desc 
limit 5;

--Top 5 Mostly Liked Vidoes of a particular channel.
select ch.channel_name, vd.title, vd.likes
from channels ch 
inner join videos vd using(channel_id)
where ch.channel_id ilike 'UCO5QSoES5yn2Dw7YixDYT5Q' 
group by ch.channel_name,vd.title,vd.likes
order by vd.likes desc 
limit 5;

--Top 5 Mostly Commented Vidoes of a particular channel.
select ch.channel_name, vd.title, vd.comments
from channels ch 
inner join videos vd using(channel_id)
where ch.channel_id ilike 'UCO5QSoES5yn2Dw7YixDYT5Q' 
group by ch.channel_name,vd.title,vd.comments
order by vd.comments desc 
limit 5;







