{{
    config(
        materialized='view'
    )
}}

select
    date(timestamp) as date,
    cast(gender as string) as gender,
    cast(country as string) as country,
    cast(occupation as string) as occupation,
    {{ transform_boolean('self_employed') }} as self_employed,
    {{ transform_boolean('family_history') }} as family_history,
    {{ transform_boolean('treatment') }} as treatment,
    cast(days_indoors as string) as days_indoors,
    cast(growing_stress as string) as growing_stress,
    cast(changes_habits as string) as changes_habits,
    cast(mental_health_history as string) as mental_health_history,
    cast(mood_swings as string) as mood_swings,
    {{ transform_boolean('coping_struggles') }} as coping_struggles,
    cast(work_interest as string) as work_interest,
    cast(social_weakness as string) as social_weakness,
    cast(mental_health_interview as string) as mental_health_interview,
    cast(care_options as string) as care_options,
from
    {{ source('staging','mental_health') }}

-- dbt build --select <model_name> --vars '{"is_test_run": false}'
{% if var('is_test_run', default=true) %}

  limit 100

{% endif %}