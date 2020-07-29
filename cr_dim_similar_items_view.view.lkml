view: dim_similar_items {
  sql_table_name:  {{ _user_attributes["cr_tenant_id"] }}.Dim_Similar_Items_View ;;
  label: "Similar Items"

  dimension: item_id {
    group_label: "Items" label: "Items Ids"
    type: string
    sql: IFNULL(${TABLE}.ItemId, 'Unknown') ;;
  }

  dimension: item_name {
    group_label: "Items" label: "Items"
    type: string
    sql: IFNULL(${TABLE}.ItemName, 'Unknown') ;;
  }

  dimension: department {
    group_label: "Items" label: "Departments"
    type: string
    sql: IFNULL(${TABLE}.Department, 'Unknown') ;;
  }

  dimension: similar_item_id {
    group_label: "Items" label: "Similar Items Ids"
    type: string
    sql: IFNULL(${TABLE}.SimilarItemId, 'Unknown') ;;
  }

  dimension: similar_item_name {
    group_label: "Items" label: "Similar Items"
    type: string
    sql: IFNULL(${TABLE}.SimilarItemName, 'Unknown') ;;
  }

  dimension: similar_item_department {
    group_label: "Items" label: "Similar Departments"
    type: string
    sql: IFNULL(${TABLE}.SimilarItemDepartment, 'Unknown') ;;
  }

  dimension: match_level {
    group_label: "Items" label: "Match Level"
    type: number
    value_format_name: decimal_2
    sql: ${TABLE}.MatchLevel ;;
  }


  measure: count {
    type: count
    drill_fields: [item_name]
    hidden: yes
  }
}
