select *
from {{ source("amazon", "sale_report")}}