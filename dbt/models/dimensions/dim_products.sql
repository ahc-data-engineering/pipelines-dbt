with prds as (
    select
         "SKU" as product_sku
        ,"ASIN" as product_asin
    from {{ ref("amazon_sale_report") }}
    group by "SKU", "ASIN"
),
products as (
    select distinct
         prds.product_sku
        ,prds.product_asin
        ,ref."Style" as product_style
        ,ref."Size" as product_size
    from {{ ref("amazon_sale_report") }} ref
    inner join prds
        on ref."SKU" = prds.product_sku
            and ref."ASIN" = prds.product_asin
)

select
     {{ dbt_utils.generate_surrogate_key(["products.product_sku", "products.product_asin"]) }} as product_sk
    ,products.product_sku
    ,products.product_asin
    ,products.product_style
    ,products.product_size
from products
{% if is_incremental() %}
where 
    (select count(*) from {{ this }} t where t.product_sku = products.product_sku and t.product_asin = products.product_asin) = 0
{% endif %}