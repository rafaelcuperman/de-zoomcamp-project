{#
    This macro returns the description of the payment_type 
#}

{% macro transform_boolean(boolean_column) -%}

    case {{ boolean_column }}  
        when false then 'No'
        when true then 'Yes'
        else null
    end

{%- endmacro %}