-- models/marts/dim_trip.sql
--
-- 職責：旅遊行為維度表。
--       從 int_trip_behavior 取出旅遊型態、住宿、
--       活動、交通欄位。
--
-- Materialization：table

{{ config(materialized='table') }}

with source as (

    select * from {{ ref('int_trip_behavior') }}

),

final as (

    select

        -- ── Surrogate Key ─────────────────────────────────
        {{ dbt_utils.generate_surrogate_key(['tourist_id']) }}
                                        as trip_key,

        tourist_id,

        -- ── 旅遊安排 ──────────────────────────────────────
        travel_arrangement_code,
        travel_type,
        is_independent_traveler,

        -- ── 停留 ──────────────────────────────────────────
        stay_nights,
        stay_group,
        visit_frequency,
        plan_days_ahead,
        is_repeat_visitor,

        -- ── 住宿 ──────────────────────────────────────────
        primary_accommodation,
        stayed_hotel,
        stayed_bnb,
        stayed_relatives,

        -- ── 活動 ──────────────────────────────────────────
        activity_count,
        did_nightmarket,
        did_shopping,
        did_historic_sites,
        did_hiking,
        did_festival,
        did_massage,
        did_exhibition,

        -- ── 交通 ──────────────────────────────────────────
        used_hsr,
        used_tra,
        used_mrt,
        used_taxi,
        used_uber

    from source

)

select * from final
