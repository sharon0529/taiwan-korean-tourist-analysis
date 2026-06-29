-- models/marts/dim_spending_detail.sql
--
-- 職責：消費細項維度表。
--       從 int_spending_cleaned 取出各項支出金額、
--       比例、離群值標記，供 Looker Studio 消費結構圖使用。
--
-- Materialization：table

{{ config(materialized='table') }}

with source as (

    select * from {{ ref('int_spending_cleaned') }}

),

final as (

    select

        -- ── Surrogate Key ─────────────────────────────────
        {{ dbt_utils.generate_surrogate_key(['tourist_id']) }}
                                        as spending_key,

        tourist_id,

        -- ── 幣別資訊 ──────────────────────────────────────
        currency_original,
        fx_rate,

        -- ── 各項支出（台幣）──────────────────────────────
        total_spend_twd,
        hotel_spend_twd,
        food_spend_twd,
        transport_spend_twd,
        entertainment_spend_twd,
        misc_spend_twd,
        shopping_spend_twd,

        -- ── 購物細項（台幣）──────────────────────────────
        shopping_cosmetics_twd,
        shopping_local_products_twd,
        shopping_souvenir_twd,
        shopping_clothing_twd,
        shopping_medicine_twd,

        -- ── 衍生指標 ──────────────────────────────────────
        spend_per_day_twd,

        -- 消費結構比例（Looker Studio 圓餅圖用）
        hotel_spend_pct,
        food_spend_pct,
        shopping_spend_pct,
        transport_spend_pct,

        -- ── 資料品質標記 ──────────────────────────────────
        is_outlier,
        p99_total_spend

    from source

)

select * from final
