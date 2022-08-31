insert into dm_rfm_segments (user_id, recency, frequency, monetary_value)
select r.user_id,
       recency,
       frequency,
       monetary_value 
from analysis.tmp_rfm_recency as r full outer join analysis.tmp_rfm_frequency as f on r.user_id  = f.user_id
full outer join analysis.tmp_rfm_monetary_value as m on r.user_id  = m.user_id;
/*
user_id|recency|frequency|monetary_value|
-------+-------+---------+--------------+
      0|      3|        5|             5|
      1|      3|        4|             4|
      2|      4|        3|             3|
      3|      3|        3|             2|
      4|      3|        4|             2|
      5|      2|        5|             5|
      6|      5|        2|             2|
      7|      1|        1|             2|
      8|      2|        1|             2|
      9|      3|        3|             2|*/