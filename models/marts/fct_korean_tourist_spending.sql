-- models/marts/fct_korean_tourist_spending.sql
--
-- 職責：韓國旅客消費行為 Fact table。
--       Join 所有 dim tables，每筆代表一位旅客的完整旅程。
--       這是 Looker Studio 的主要資料來源。
--
-- Grain：一列 = 一位受訪旅客（tourist_id）
--
-- Materialization：table（fct 層固定用 table，Dashboard 查詢效能優先）

{{ config(materialized='table') }}

with tourists as (

    select * from {{ ref('dim_tourist') }}

),

trips as (

    select * from {{ ref('dim_trip') }}

),

spending as (

    select * from {{ ref('dim_spending_detail') }}

),

final as (

    select

        -- ── 主鍵 ──────────────────────────────────────────
        t.tourist_id,

        -- ── 外鍵（對應各 dim table）──────────────────────
        t.tourist_key,
        tr.trip_key,
        s.spending_key,

        -- ── 調查月份（時間維度，dim_date 簡化版）─────────
        -- 本專案資料只有單一年度（113年），
        -- 不另建 dim_date，直接帶入 survey_month 供月趨勢分析
        t.survey_month,

        -- ── 人口統計維度（來自 dim_tourist）──────────────
        t.age_group,
        t.gender,
        t.education_level,
        t.income_band,
        t.occupation,
        t.primary_purpose,

        -- ── 旅遊行為維度（來自 dim_trip）─────────────────
        tr.travel_type,
        tr.is_independent_traveler,
        tr.stay_nights,
        tr.stay_group,
        tr.visit_frequency,
        tr.is_repeat_visitor,
        tr.primary_accommodation,
        tr.activity_count,

        -- 活動 flags
        tr.did_nightmarket,
        tr.did_shopping,
        tr.did_historic_sites,
        tr.did_hiking,
        tr.did_festival,

        -- 交通 flags
        tr.used_hsr,
        tr.used_mrt,
        tr.used_taxi,
        tr.used_uber,

        -- ── 消費 Measures（來自 dim_spending_detail）─────
        s.total_spend_twd,
        s.hotel_spend_twd,
        s.food_spend_twd,
        s.transport_spend_twd,
        s.entertainment_spend_twd,
        s.shopping_spend_twd,

        -- 購物細項
        s.shopping_cosmetics_twd,
        s.shopping_local_products_twd,
        s.shopping_souvenir_twd,
        s.shopping_clothing_twd,
        s.shopping_medicine_twd,

        -- 衍生指標
        s.spend_per_day_twd,
        s.hotel_spend_pct,
        s.food_spend_pct,
        s.shopping_spend_pct,
        s.transport_spend_pct,

        -- ── 滿意度與回訪（Measures / 分析維度皆可）───────
        t.overall_satisfaction,
        t.satisfaction_label,
        t.would_revisit,
        t.would_recommend,

        -- ── 資料品質 ──────────────────────────────────────
        s.is_outlier,
        s.currency_original

    from tourists t
    left join trips tr
        on t.tourist_id = tr.tourist_id
    left join spending s
        on t.tourist_id = s.tourist_id

)

select * from final
