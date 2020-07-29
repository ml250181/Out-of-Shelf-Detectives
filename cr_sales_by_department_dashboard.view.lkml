include: "cr_sales_by_department.view"
view: sales_by_department_dashboard {
  extends: [sales_by_department]

  dimension_group: business {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year,
      day_of_week,
      day_of_week_index,
      quarter_of_year
    ]
    convert_tz: no
    datatype: date
    hidden: no
    sql: ${TABLE}.BusinessDate ;;
  }

  dimension_group: open_date_time {
    type: time
    timeframes: [
      raw,
      time,
      time_of_day,
      hour_of_day,
      minute,
      minute15,
      hour2,
      day_of_week,
      day_of_week_index,
      date,
      week,
      month,
      month_num,
      month_name,
      quarter,
      year,
      quarter_of_year
    ]
    convert_tz: no
    datatype: timestamp
    hidden: no
    sql: ${TABLE}.OpenDateTime ;;
  }

  dimension: day_type {
    label: "Day type"
    type: string
    sql: CASE WHEN ${open_date_time_day_of_week_index} < 5 THEN "Week Day" ELSE "Week End" END  ;;
  }

  dimension: item_id {
    group_label: "Items" label: "Item IDs"
    type: string
    sql: ${TABLE}.ItemId ;;
    link:{
      label: "Similar Items"
      url:"@{looker_url}/looks/630?&f[dim_similar_items.item_id]={{dim_items.item_id | url_encode }}
      &f[dim_similar_items.item_name]={{dim_items.item_name | url_encode }}"
    }
    link:{
      label: "Hourly Trend"
      url:"@{looker_url}/looks/631?toggle=pik&f[sales_by_department_dashboard.item_id]={{sales_by_department_dashboard.item_id | url_encode }}
      &f[dim_items.item_name]={{dim_items.item_name | url_encode }}
      &f[sales_by_department_dashboard.timeframe_a]={{_filters['sales_by_department_dashboard.timeframe_a'] | url_encode }}
      &f[sales_by_department_dashboard.timeframe_b]={{_filters['sales_by_department_dashboard.timeframe_b'] | url_encode }}
      &f[sales_by_department_dashboard.day_type]={{_filters['sales_by_department_dashboard.day_type'] | url_encode }}
      &f[sales_by_department_dashboard.open_date_time_day_of_week]={{_filters['sales_by_department_dashboard.open_date_time_day_of_week'] | url_encode }}
      &f[sales_by_department_dashboard.open_date_time_hour_of_day]=%3C%3D{{_filters['sales_by_department_dashboard.open_date_time_hour_of_day'] | url_encode }}
      &f[dim_stores.store_name]={{_filters['dim_stores.store_name'] | url_encode }}"
    }
  }


  parameter: Incrase_or_Decrease {
    description: "Incrase or Decrease"
    type: unquoted
    allowed_value: {
      label: "Incrase"
      value: "Incrase"
    }
    allowed_value: {
      label: "Decrease"
      value: "Decrease"
    }
  }

  parameter: max_rank {
    label: "Max Rank"
    hidden: yes
    type: number
  }


  dimension: rank_limit {
    label: "Rank Limit"
    type: number
    hidden: yes
    sql: {% parameter max_rank %} ;;
  }


  filter: Day_filter {
    type: date_time
    hidden: yes
    description: "Use this filter for period analysis"
  }

  dimension: Named_periods {
    type: string
    description: "The reporting period as selected by the Previous Period Filter"
    label: "Period"
    hidden: yes
    sql:
      --  WHEN ${businessDate}  =  add_days(-7 , ${Day_filter}) THEN 'Same Day Week Before'

    CASE
    WHEN {% date_start Day_filter %} is not null AND {% date_end Day_filter %} is not null /* date ranges or in the past x days */
      THEN
        CASE
          WHEN CAST(${businessDate} AS TIMESTAMP) =  CAST({% date_start Day_filter %} AS TIMESTAMP) THEN 'Day'
          WHEN CAST(${businessDate} AS TIMESTAMP) =  CAST(TIMESTAMP_ADD({% date_start Day_filter %}, INTERVAL -7 DAY ) AS TIMESTAMP) THEN 'Same Day 1 Week Before'
          WHEN CAST(${businessDate} AS TIMESTAMP) =  CAST(TIMESTAMP_ADD({% date_start Day_filter %}, INTERVAL -14 DAY ) AS TIMESTAMP) THEN 'Same Day 2 Weeks Before'
          WHEN CAST(${businessDate} AS TIMESTAMP) =  CAST(TIMESTAMP_ADD({% date_start Day_filter %}, INTERVAL -28 DAY ) AS TIMESTAMP) THEN 'Same Day Month Before'
          WHEN CAST(${businessDate} AS TIMESTAMP) =  CAST(TIMESTAMP_ADD({% date_start Day_filter %}, INTERVAL -364 DAY ) AS TIMESTAMP) THEN 'Same Day Year Before'
        END
      END ;;
  }


  ## filter determining time range for all "A" , "B" measures


  filter: timeframe_a {
    label: "Period"
    group_label: "Time Comparison Filters"
    type: date
    datatype: date
  }

  filter: timeframe_b {
    label: "Reference Period"
    group_label: "Time Comparison Filters"
    type: date
    datatype: date
  }

  filter: timeframe_odt {
    label: "Open Date Time Period"
    group_label: "Time Comparison Filters"
    type: date_time
    datatype: timestamp
  }

  ## flag for "A", "B" measures to only include appropriate time range

  dimension: group_a_yesno {
    hidden: yes
    type: yesno
    sql: {% condition timeframe_a %} ${business_raw} {% endcondition %} ;;
  }

  dimension: group_b_yesno {
    hidden: yes
    type: yesno
    sql: {% condition timeframe_b %} ${business_raw} {% endcondition %} ;;
  }

  dimension: group_odt_yesno {
    hidden: yes
    type: yesno
    sql: {% condition timeframe_odt %} ${open_date_time_raw} {% endcondition %} ;;
  }

  dimension: is_in_time_a_or_b {
    label: "Is in Period/Reference Period"
    group_label: "Time Comparison Filters"
    type: yesno
    sql:
      {% condition timeframe_a %} ${business_raw} {% endcondition %} OR
      {% condition timeframe_b %} ${business_raw} {% endcondition %}
      ;;
  }

  dimension: is_in_time_odt {
    label: "Is in Open Date Time Period"
    group_label: "Time Comparison Filters"
    type: yesno
    sql:
      {% condition timeframe_odt %} ${open_date_time_raw} {% endcondition %}
      ;;
  }


  ## filtered measures

  measure: total_net_sales_a {
    label: "Net Sales in Period"
    type: sum
    sql: ${net_sales} ;;
    value_format_name: usd
    filters: {
      field: group_a_yesno
      value: "yes"
    }
  }

  measure: total_net_sales_b {
    label: "Net Sales in Reference Period"
    type: sum
    sql: ${net_sales} ;;
    value_format_name: usd
    filters: {
      field: group_b_yesno
      value: "yes"
    }
  }

  measure: total_net_sales_odt {
    type: sum
    sql: ${net_sales} ;;
    value_format_name: usd
    filters: {
      field: group_odt_yesno
      value: "yes"
    }
  }

  measure: total_quantity_a {
    label: "Qty in Period"
    type: sum
    sql: ${item_quantity}+${weighted_quantity} ;;
    value_format_name: decimal_1
    filters: {
      field: group_a_yesno
      value: "yes"
    }
  }

  measure: total_quantity_b {
    label: "Qty in Reference Period"
    type: sum
    sql: ${item_quantity}+${weighted_quantity} ;;
    value_format_name: decimal_1
    filters: {
      field: group_b_yesno
      value: "yes"
    }
  }

  measure: total_quantity_odt {
    label: "Qty in Period (Open Date Period)"
    type: sum
    sql: ${item_quantity}+${weighted_quantity} ;;
    value_format_name: decimal_1
    filters: {
      field: group_odt_yesno
      value: "yes"
    }
  }

  measure: date_start_a {
    type: date
    sql: {% date_start timeframe_a %}  ;;
    convert_tz: no
  }

  measure: date_end_a {
    type: date
    sql: {% date_end timeframe_a %}  ;;
    convert_tz: no
  }

  measure: date_start_b {
    type: date
    sql: {% date_start timeframe_b %}  ;;
    convert_tz: no
  }

  measure: date_end_b {
    type: date
    sql: {% date_end timeframe_b %}  ;;
    convert_tz: no
  }

  measure: date_start_odt {
    type: date_time
    sql: {% date_start timeframe_odt %}  ;;
  }

  measure: date_end_odt {
    type: date_time
    sql: {% date_end timeframe_odt %}  ;;
  }

  measure: date_range_a {
    type: number
    sql: DATE_DIFF(${date_end_a},${date_start_a},DAY)  ;;
    value_format_name: decimal_0
  }

  measure: date_range_b {
    type: number
    sql: DATE_DIFF(${date_end_b},${date_start_b},DAY)  ;;
    value_format_name: decimal_0
  }

  measure: date_range_odt {
    type: number
    sql: DATETIME_DIFF(PARSE_DATETIME('%Y-%m-%d %H:%M:%S',${date_end_odt}),PARSE_DATETIME('%Y-%m-%d %H:%M:%S',${date_start_odt}),DAY)  ;;
    value_format_name: decimal_0
  }

  measure: count_distinct_dates_a {
    label: "Period - Number of shows"
    type: count_distinct
    sql: ${business_date} ;;
    value_format_name: decimal_0
    filters: {
      field: group_a_yesno
      value: "yes"
    }
    hidden: no
  }

  measure: count_distinct_dates_b {
    label: "Reference Period - Number of shows"
    type: count_distinct
    sql: ${business_date} ;;
    value_format_name: decimal_0
    filters: {
      field: group_b_yesno
      value: "yes"
    }
    hidden: no
  }

  measure: count_distinct_dates_odt {
    type: count_distinct
    sql: ${open_date_time_date} ;;
    value_format_name: decimal_0
    filters: {
      field: group_odt_yesno
      value: "yes"
    }
    hidden: no
  }

  measure: average_net_sales_a {
    label: "Avg Sales in Period"
    type: number
    sql: CASE WHEN ${total_net_sales_a} = 0 THEN 0 ELSE NULLIF(${total_net_sales_a},0) / ${count_distinct_dates_a} END;;
    value_format_name: usd
  }

  measure: average_net_sales_b {
    label: "Avg Sales in Reference Period"
    type: number
    sql: CASE WHEN ${total_net_sales_b} = 0 THEN 0 ELSE NULLIF(${total_net_sales_b},0) / ${count_distinct_dates_b} END;;
    value_format_name: usd
  }

  measure: loss_of_sales {
    label: "Estimated Loss of Sales"
    type: number
    sql: ${average_net_sales_b}-${average_net_sales_a} ;;
    value_format_name: usd
  }

  measure: average_quantity_a {
    label: "Avg Qty in Period"
    type: number
    sql:  CASE WHEN ${total_quantity_a} = 0 THEN 0 ELSE NULLIF(${total_quantity_a},0) / ${count_distinct_dates_a} END;;
    value_format_name: decimal_1
  }

  measure: average_quantity_b {
    label: "Avg Qty in Reference Period"
    type: number
    sql:  CASE WHEN ${total_quantity_b} = 0 THEN 0 ELSE NULLIF(${total_quantity_b},0) / ${count_distinct_dates_b} END;;
    value_format_name: decimal_1
  }

  measure: average_quantity_odt {
    label: "Avg Qty in Open Date Time Period"
    type: number
    sql: CASE WHEN ${total_quantity_odt} = 0 THEN 0 ELSE NULLIF(${total_quantity_odt},0) / ${count_distinct_dates_odt} END;;
    value_format_name: decimal_1
  }


  measure:  average_net_sales_change {
    label: "Net Sales Change"
    type: number
    sql: (${average_net_sales_a}-${average_net_sales_b})/${average_net_sales_b} ;;
    value_format_name: percent_1
  }

  measure:  average_quantity_change {
    label: "Item Quantity Change"
    type: number
    sql: (${average_quantity_a}-${average_quantity_b})/${average_quantity_b} ;;
    value_format_name: percent_1
  }

  measure:  average_quantity_change_odt {
    label: "Item Quantity Change (Open Date Period)"
    type: number
    sql: (${average_quantity_odt}-${average_quantity_b})/${average_quantity_b} ;;
    value_format_name: percent_1
  }


  measure: increase_decrease {
    type: string
    sql: CASE WHEN NULLIF(${average_net_sales_a},0) >= NULLIF(${average_net_sales_b},0) THEN 'INCREASE' ELSE 'DECREASE' END ;;
  }


  ##### Custom Fields #####


  filter: previous_period_filter {
    type: date
    datatype: date
    hidden: no
    description: "Use this filter for period analysis"
    sql:
    {% if previous_period._in_query %}
    (${business_date}  >=  {% date_start previous_period_filter %}
      AND ${business_date}  < {% date_end previous_period_filter %})
    OR
    (${business_date} >=
              DATE_ADD(DATE_ADD({% date_start previous_period_filter %}, INTERVAL -1 DAY ), INTERVAL
                -1*DATE_DIFF({% date_end previous_period_filter %}, {% date_start previous_period_filter %}, DAY) + 1 DAY)
                AND ${business_date} <=
                DATE_ADD({% date_start previous_period_filter %}, INTERVAL -1 DAY ) )
    {% else %}
    {% condition previous_period_filter %} ${business_date} {% endcondition %}
    {% endif %}
    ;;
  }

  dimension: previous_period_start {
    type: date
    datatype: date
    sql:
      CASE
        WHEN {% date_start previous_period_filter %} is not null AND {% date_end previous_period_filter %} is not null /* date ranges or in the past x days */
          THEN
            CASE
              WHEN ${business_date}  >=  {% date_start previous_period_filter %}
                    AND ${business_date} < {% date_end previous_period_filter %}
              THEN {% date_start previous_period_filter %}
              ELSE DATE_ADD(DATE_ADD({% date_start previous_period_filter %}, INTERVAL -1 DAY ), INTERVAL
                   -1*DATE_DIFF({% date_end previous_period_filter %}, {% date_start previous_period_filter %}, DAY) + 1 DAY)
            END
      END
      ;;
  }

  dimension: previous_period_end {
    type: date
    datatype: date
    sql:
      CASE
        WHEN {% date_start previous_period_filter %} is not null AND {% date_end previous_period_filter %} is not null /* date ranges or in the past x days */
          THEN
            CASE
              WHEN ${business_date}  >=  {% date_start previous_period_filter %}
                    AND ${business_date} < {% date_end previous_period_filter %}
              THEN {% date_end previous_period_filter %}
              ELSE {% date_start previous_period_filter %}
            END
      END
      ;;
  }


  dimension: previous_period_range {
    type: string
    sql: CONCAT(CAST(${previous_period_start} AS STRING)," to ", CAST(${previous_period_end} AS STRING))  ;;
  }

  dimension: previous_period {
    type: string
    hidden: no
    description: "The reporting period as selected by the Previous Period Filter"
    label: "Period"
    sql:
      CASE
        WHEN {% date_start previous_period_filter %} is not null AND {% date_end previous_period_filter %} is not null /* date ranges or in the past x days */
          THEN
            CASE
              WHEN ${business_date}  >= {% date_start previous_period_filter %}
                AND ${business_date} <  {% date_end previous_period_filter %}
                THEN 'This Period'
              WHEN ${business_date} >= DATE_ADD(DATE_ADD({% date_start previous_period_filter %}, INTERVAL -1 DAY ), INTERVAL
                -1*DATE_DIFF({% date_end previous_period_filter %}, {% date_start previous_period_filter %}, DAY) + 1 DAY)
                AND ${business_date} <= DATE_ADD({% date_start previous_period_filter %}, INTERVAL -1 DAY )
                THEN 'Previous Period'
            END
          END ;;
  }


  parameter: time_line {
    hidden: yes
    type: unquoted
    allowed_value: {
      label: "Date"
      value:  "business_date"
    }
    allowed_value: {
      label: "Week"
      value: "business_week"
    }
    allowed_value: {
      label: "Month"
      value: "business_month"
    }
  }


  dimension: dynamic_time_line {
    hidden: yes
    label_from_parameter: time_line
    sql:  case when {% condition time_line %} 'business_date' {% endcondition %}  then cast(${business_date} as string)
              when {% condition time_line %} 'business_week' {% endcondition %}  then cast(${business_week} as string)
              when {% condition time_line %} 'business_month' {% endcondition %}  then  cast(${business_month} as string)
              else null end ;;
  }


  parameter: measure_type {
    hidden: yes
    suggestions: ["Sum","Average"]
  }


  parameter: measure_to_aggregate {
    hidden: yes
    type: unquoted
    allowed_value: {
      label: "Gross Sales"
      value: "GrossSales"
    }
    allowed_value: {
      label: "Grand Sales"
      value: "GrandSales"
    }
    allowed_value: {
      label: "Net Sales"
      value: "NetSales"
    }
    allowed_value: {
      label: "Fees"
      value: "Fees"
    }
    allowed_value: {
      label: "Tax"
      value: "Tax"
    }
    allowed_value: {
      label: "Item Quantity"
      value: "ItemQuantity"
    }
    allowed_value: {
      label: "Weighted Quantity"
      value: "WeightedQuantity"
    }

  }


  ##### Measures #####

  measure: period_start {
    label: "Period Start"
    type: date
    sql: MAX(${previous_period_start})  ;;
  }

  measure: period_end {
    label: "Period End"
    type: date
    sql: MAX(${previous_period_end})  ;;
  }

  measure: period_range {
    label: "Period Range"
    type: string
    sql: MAX(${previous_period_range})  ;;
  }


  measure: total_net_sales {
    label: "Net Sales"
    type: sum
    sql: ${net_sales} ;;
    value_format_name: usd
    link:{
      label: "{% if sales_by_department_dashboard.previous_period._is_selected %}Sales by Department{% endif %}"
      url:"@{looker_url}/looks/@{sales_by_department_look_id}?
      {% if sales_by_department_dashboard.previous_period._is_selected %}&f[sales_by_department.BusinessDate]={{ sales_by_department_dashboard.period_range | url_encode }}
      {% elsif sales_by_department_dashboard.previous_period_filter._is_filtered %}&f[sales_by_department.BusinessDate]={{ _filters['sales_by_department_dashboard.previous_period_filter'] | url_encode }}
      {% elsif sales_by_department_dashboard.BusinessDate._is_filtered %}&f[sales_by_department.BusinessDate]={{ _filters['sales_by_department_dashboard.BusinessDate'] | url_encode }}
      {% endif %}
      {% if dim_items.department._is_selected %}&f[dim_items.department]={{ dim_items.department | url_encode }}
      {% endif %}
      {% if dim_stores.store_name._is_selected %}&f[dim_stores.store_name]={{ dim_stores.store_name | url_encode }}
      {% else %}&f[dim_stores.store_name]={{ _filters['dim_stores.store_name'] | url_encode }}
      {% endif %}"
    }
  }

}
