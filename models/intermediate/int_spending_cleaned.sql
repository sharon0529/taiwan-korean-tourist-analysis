-- models/intermediate/int_spending_cleaned.sql
--
-- 職責：
--   1. 從 stg_spending 取得已換算台幣的消費欄位
--   2. 從 stg_korean_tourists 取得 stay_nights（計算人均日支出用）
--   3. 標記離群值（total_spend_twd 超過 99 百分位）
--   4. 計算人均日支出（spend_per_day_twd）
--
-- 離群值處理策略：
--   標記（is_outlier = true）而非刪除，保留原始資料完整性。
--   marts 層的 fct 可依需求決定是否排除。
--
-- Materialization：view

{{ config(materialized='view') }}

with spending as (

    select * from {{ ref('stg_spending') }}

),

tourists as (

    select
        tourist_id,
        stay_nights
    from {{ ref('stg_korean_tourists') }}

),

joined as (

    select
        s.*,
        t.stay_nights

    from spending s
    left join tourists t
        on s.tourist_id = t.tourist_id

),

-- BigQuery 寫法：percentile_cont 是 analytic function，需用 subquery 取單一值
percentiles as (

    select max(p99) as p99_total_spend
    from (
        select percentile_cont(total_spend_twd, 0.99) over () as p99
        from joined
        limit 1
    )

),

final as (

    select
        j.*,

        -- ── 離群值標記 ────────────────────────────────────
        case when j.total_spend_twd > p.p99_total_spend
            then true else false
        end                             as is_outlier,

        p.p99_total_spend,

        -- ── 人均日支出 ────────────────────────────────────
        round(
            cast(j.total_spend_twd as numeric)
            / nullif(j.stay_nights, 0),
        0)                              as spend_per_day_twd,

        -- ── 消費結構比例 ──────────────────────────────────
        case when j.total_spend_twd > 0
            then round(cast(j.hotel_spend_twd as numeric)    / j.total_spend_twd * 100, 1)
            else 0
        end                             as hotel_spend_pct,

        case when j.total_spend_twd > 0
            then round(cast(j.food_spend_twd as numeric)     / j.total_spend_twd * 100, 1)
            else 0
        end                             as food_spend_pct,

        case when j.total_spend_twd > 0
            then round(cast(j.shopping_spend_twd as numeric) / j.total_spend_twd * 100, 1)
            else 0
        end                             as shopping_spend_pct,

        case when j.total_spend_twd > 0
            then round(cast(j.transport_spend_twd as numeric)/ j.total_spend_twd * 100, 1)
            else 0
        end                             as transport_spend_pct

    from joined j
    cross join percentiles p

)

select * from final