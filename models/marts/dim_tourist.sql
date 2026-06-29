-- models/marts/dim_tourist.sql
--
-- 職責：人口統計維度表。
--       從 int_tourist_profile 取出所有維度欄位，
--       加上 surrogate key 供 fct table join 使用。
--
-- Materialization：table（dim 層固定用 table，避免每次 join 都重算）

{{ config(materialized='table') }}

with source as (

    select * from {{ ref('int_tourist_profile') }}

),

final as (

    select

        -- ── Surrogate Key ─────────────────────────────────
        -- dbt_utils.generate_surrogate_key 用欄位值組合產生 hash key
        -- 確保同一位旅客在不同 run 之間 key 不變
        {{ dbt_utils.generate_surrogate_key(['tourist_id']) }}
                                        as tourist_key,

        -- ── 自然鍵 ────────────────────────────────────────
        tourist_id,
        survey_month,

        -- ── 人口統計（code + label 並存）─────────────────
        age_code,
        age_group,

        gender_code,
        gender,

        education_code,
        education_level,

        income_code,
        income_band,

        occupation_code,
        occupation,

        -- ── 來台目的 ──────────────────────────────────────
        primary_purpose_code,
        primary_purpose,

        -- ── 滿意度與回訪 ──────────────────────────────────
        overall_satisfaction,
        satisfaction_label,
        would_revisit,
        would_recommend

    from source

)

select * from final
