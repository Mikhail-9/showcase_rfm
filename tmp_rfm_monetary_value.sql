insert into analysis.tmp_rfm_monetary_value (user_id, monetary_value)
select u.id,
       ntile(5) over (order by sum(payment)) as monetary_value
from analysis.users u  
LEFT JOIN analysis.orders o ON u.id = o.user_id
                           AND o.order_ts >= '2021-01-01'
                           AND o.status = 4 
group by u.id;