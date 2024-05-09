with orders as (
    select
         "Order ID" as order_id
        ,min("Date") as order_date
    from {{ ref("amazon_sale_report") }}
    group by "Order ID"
)

select
     {{ dbt_utils.generate_surrogate_key(["orders.order_id"]) }} as order_sk
    ,orders.order_id
    ,orders.order_date
from orders
{% if is_incremental() %}
where 
    orders.order_id not in (select order_id from {{ this }})
{% endif %}