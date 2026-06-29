-- models/staging/stg_spending.sql
--
-- 職責：將 stg_korean_tourists 的消費金額，
--       依原始幣別統一換算為新台幣（TWD）。
--       此層只做換算，不做任何篩選或邏輯判斷。
--
-- 固定匯率（2024 年均值）：
--   韓元 (KRW) → TWD : × 0.023
--   美元 (USD) → TWD : × 32.5
--   日圓 (JPY) → TWD : × 0.21
--   新台幣      → TWD : × 1（不動）
--
-- Materialization：view

{{ config(materialized='view') }}

with base as (

    select * from {{ ref('stg_korean_tourists') }}

),

converted as (

    select

        tourist_id,
        currency_original,

        -- ── 換算係數 ──────────────────────────────────────
        case currency_original
            when '新台幣' then 1.0
            when '韓元'   then 0.023
            when '美元'   then 32.5
            when '日圓'   then 0.21
            else 1.0  -- 其他幣別極少（共 2 筆），fallback 為 1
        end as fx_rate,

        -- ── 總支出 ────────────────────────────────────────
        round(total_spend_raw * case currency_original
            when '新台幣' then 1.0
            when '韓元'   then 0.023
            when '美元'   then 32.5
            when '日圓'   then 0.21
            else 1.0
        end, 0)                         as total_spend_twd,

        -- ── 各項支出 ─────────────────────────────────────
        round(coalesce(hotel_spend_raw, 0) * case currency_original
            when '新台幣' then 1.0
            when '韓元'   then 0.023
            when '美元'   then 32.5
            when '日圓'   then 0.21
            else 1.0
        end, 0)                         as hotel_spend_twd,

        round(coalesce(food_outside_hotel_raw, 0) * case currency_original
            when '新台幣' then 1.0
            when '韓元'   then 0.023
            when '美元'   then 32.5
            when '日圓'   then 0.21
            else 1.0
        end, 0)                         as food_spend_twd,

        round(coalesce(local_transport_raw, 0) * case currency_original
            when '新台幣' then 1.0
            when '韓元'   then 0.023
            when '美元'   then 32.5
            when '日圓'   then 0.21
            else 1.0
        end, 0)                         as transport_spend_twd,

        round(coalesce(entertainment_raw, 0) * case currency_original
            when '新台幣' then 1.0
            when '韓元'   then 0.023
            when '美元'   then 32.5
            when '日圓'   then 0.21
            else 1.0
        end, 0)                         as entertainment_spend_twd,

        round(coalesce(miscellaneous_raw, 0) * case currency_original
            when '新台幣' then 1.0
            when '韓元'   then 0.023
            when '美元'   then 32.5
            when '日圓'   then 0.21
            else 1.0
        end, 0)                         as misc_spend_twd,

        round(coalesce(shopping_raw, 0) * case currency_original
            when '新台幣' then 1.0
            when '韓元'   then 0.023
            when '美元'   then 32.5
            when '日圓'   then 0.21
            else 1.0
        end, 0)                         as shopping_spend_twd,

        -- ── 購物細項 ─────────────────────────────────────
        round(coalesce(shopping_cosmetics_raw, 0) * case currency_original
            when '新台幣' then 1.0
            when '韓元'   then 0.023
            when '美元'   then 32.5
            when '日圓'   then 0.21
            else 1.0
        end, 0)                         as shopping_cosmetics_twd,

        round(coalesce(shopping_local_products_raw, 0) * case currency_original
            when '新台幣' then 1.0
            when '韓元'   then 0.023
            when '美元'   then 32.5
            when '日圓'   then 0.21
            else 1.0
        end, 0)                         as shopping_local_products_twd,

        round(coalesce(shopping_souvenir_raw, 0) * case currency_original
            when '新台幣' then 1.0
            when '韓元'   then 0.023
            when '美元'   then 32.5
            when '日圓'   then 0.21
            else 1.0
        end, 0)                         as shopping_souvenir_twd,

        round(coalesce(shopping_clothing_raw, 0) * case currency_original
            when '新台幣' then 1.0
            when '韓元'   then 0.023
            when '美元'   then 32.5
            when '日圓'   then 0.21
            else 1.0
        end, 0)                         as shopping_clothing_twd,

        round(coalesce(shopping_medicine_raw, 0) * case currency_original
            when '新台幣' then 1.0
            when '韓元'   then 0.023
            when '美元'   then 32.5
            when '日圓'   then 0.21
            else 1.0
        end, 0)                         as shopping_medicine_twd

    from base

)

select * from converted
