with sales as (
    select
         "Order ID" as order_id
        ,"SKU" as product_sku
        ,"ASIN" as product_asin
    from {{ ref("amazon_sale_report") }}
    group by "Order ID", "SKU", "ASIN"
),
orders as (
    select
         order_sk
        ,order_id
        ,order_date
    from {{ ref("dim_orders") }}
),
products as (
    select
         product_sk
        ,product_sku
        ,product_asin
    from {{ ref("dim_products") }}
)

select
     {{ dbt_utils.generate_surrogate_key(["orders.order_id", "products.product_sku", "products.product_asin"]) }} as order_line_sk
    ,orders.order_sk
    ,products.product_sk
from sales
inner join orders
    on sales.order_id = orders.order_id
inner join products
    on sales.product_asin = products.product_asin
        and sales.product_sku = products.product_sku
{% if is_incremental() %}
where 
    (select count(*) from {{ this }} t where t.order_sk = orders.order_sk and t.product_sk = products.product_sk) = 0
{% endif %}