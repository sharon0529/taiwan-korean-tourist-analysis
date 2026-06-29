-- models/intermediate/int_trip_behavior.sql
--
-- 職責：整合旅遊型態、住宿、活動、交通欄位，
--       將數字 code 轉為文字，並把複選 0/1 欄位
--       整理成可讀 boolean flag。
--
-- Materialization：view

{{ config(materialized='view') }}

with base as (

    select * from {{ ref('stg_korean_tourists') }}

),

decoded as (

    select

        tourist_id,

        -- ── 旅遊安排方式 ──────────────────────────────────
        travel_arrangement_code,
        case travel_arrangement_code
            when 1 then '旅行社包辦團'
            when 2 then '自訂行程-旅行社包辦'
            when 3 then '自訂行程-旅行社訂住宿'
            when 4 then '自訂-抵台後參加OTA'
            when 5 then '完全自訂'
            else '未知'
        end                             as travel_type,

        -- 是否為散客（type 3/4/5 = 自己規劃）
        case when travel_arrangement_code in (3, 4, 5)
            then true else false
        end                             as is_independent_traveler,

        -- ── 停留與頻次 ────────────────────────────────────
        stay_nights,
        visit_frequency,
        plan_days_ahead,

        -- 停留天數分組（Looker Studio 圖表用）
        case
            when stay_nights <= 3  then '1-3晚'
            when stay_nights <= 6  then '4-6晚'
            when stay_nights <= 10 then '7-10晚'
            else '10晚以上'
        end                             as stay_group,

        -- 是否為重遊旅客
        case when visit_frequency > 1
            then true else false
        end                             as is_repeat_visitor,

        -- ── 住宿類型 ──────────────────────────────────────
        stayed_hotel,
        stayed_bnb,
        stayed_relatives,

        case
            when stayed_hotel     = 1 then '旅館'
            when stayed_bnb       = 1 then '民宿'
            when stayed_relatives = 1 then '親友家'
            else '其他'
        end                             as primary_accommodation,

        -- ── 活動參與 ──────────────────────────────────────
        did_nightmarket,
        did_shopping,
        did_historic_sites,
        did_hiking,
        did_festival,
        did_massage,
        did_exhibition,

        -- 參與活動總數（用於「活動豐富度」分析）
        (
            coalesce(did_nightmarket,   0) +
            coalesce(did_shopping,      0) +
            coalesce(did_historic_sites,0) +
            coalesce(did_hiking,        0) +
            coalesce(did_festival,      0) +
            coalesce(did_massage,       0) +
            coalesce(did_exhibition,    0)
        )                               as activity_count,

        -- ── 交通工具 ──────────────────────────────────────
        used_hsr,
        used_tra,
        used_mrt,
        used_taxi,
        used_uber

    from base

)

select * from decoded
