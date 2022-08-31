insert into analysis.tmp_rfm_frequency (user_id, frequency) 
select u.id, 
       ntile(5) over (order by count(order_id)) as frequency 
from analysis.users u  
LEFT JOIN analysis.orders o ON u.id = o.user_id
                           AND o.order_ts >= '2021-01-01'
                           AND o.status = 4 
group by u.id;