{{ config(
    materialized='table',
    partition_by={
      "field": "date",
      "data_type": "date",
      "granularity": "month"
    }
)}}

select *
from {{ ref('stg_mental_health') }}