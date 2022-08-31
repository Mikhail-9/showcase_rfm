create view analysis.orders as
   with st as (select s.status_id as status,
                      s.order_id     
               from (select order_id,
               status_id,
               date_trunc('day', max(dttm))
               from production.orderstatuslog
               where (status = 4 or (status!= 4 and status = 5 ))
               group by order_id,
               status_id) as s join production.orders as o on s.order_id = o.order_id ) 
   select o.order_id,
          o.order_ts,
          o.user_id,
          o.bonus_payment,
          o.payment,
          o."cost",
          o.bonus_grant,
          st.status
   from production.orders o join st on o.order_id = st.order_id;