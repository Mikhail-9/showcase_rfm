insert into analysis.tmp_rfm_recency (user_id, recency)
SELECT u.id,
       NTILE(5) OVER (ORDER BY (CURRENT_DATE - date_trunc('day', max(order_ts)))) as recency
from analysis.users u  
LEFT JOIN analysis.orders o ON u.id = o.user_id
                           AND o.order_ts >= '2021-01-01'
                           AND o.status = 4 
group by u.id;