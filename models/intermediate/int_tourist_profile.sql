-- models/intermediate/int_tourist_profile.sql
--
-- 職責：將 stg_korean_tourists 的人口統計 code
--       轉換為可讀文字標籤，供 dim_tourist 使用。
--       此層不做任何 join，只做 decode + 欄位整理。
--
-- Materialization：view

{{ config(materialized='view') }}

with base as (

    select * from {{ ref('stg_korean_tourists') }}

),

decoded as (

    select

        tourist_id,
        survey_month,

        -- ── 年齡 ──────────────────────────────────────────
        age_code,
        case age_code
            when 1 then '12-19歲'
            when 2 then '20-29歲'
            when 3 then '30-39歲'
            when 4 then '40-49歲'
            when 5 then '50-59歲'
            when 6 then '60-64歲'
            when 7 then '65-69歲'
            else '未知'
        end                             as age_group,

        -- ── 性別 ──────────────────────────────────────────
        gender_code,
        case gender_code
            when 1 then '男性'
            when 2 then '女性'
            else '未知'
        end                             as gender,

        -- ── 學歷 ──────────────────────────────────────────
        education_code,
        case education_code
            when 1 then '高中職以下'
            when 2 then '大專'
            when 3 then '碩博士'
            else '未知'
        end                             as education_level,

        -- ── 年收入（美元）─────────────────────────────────
        income_code,
        case income_code
            when 1 then 'USD 9,999以下'
            when 2 then 'USD 10,000-14,999'
            when 3 then 'USD 15,000-29,999'
            when 4 then 'USD 30,000-39,999'
            when 5 then 'USD 40,000-69,999'
            when 6 then 'USD 70,000-99,999'
            when 7 then 'USD 100,000以上'
            when 8 then '無固定收入'
            else '未知'
        end                             as income_band,

        -- ── 職業 ──────────────────────────────────────────
        occupation_code,
        case occupation_code
            when 1  then '民意代表/主管/經理'
            when 2  then '專業人員'
            when 3  then '技術員及助理專業'
            when 4  then '事務支援人員'
            when 5  then '服務及銷售'
            when 6  then '農林漁牧'
            when 7  then '技藝相關工作'
            when 8  then '機械設備操作'
            when 9  then '基層技術工/勞力工'
            when 10 then '家庭管理'
            when 11 then '學生'
            when 12 then '退休'
            when 13 then '其他'
            else '未知'
        end                             as occupation,

        -- ── 來台主要目的 ──────────────────────────────────
        primary_purpose_code,
        case primary_purpose_code
            when 1 then '觀光'
            when 2 then '業務'
            when 3 then '國際會議/展覽'
            when 4 then '探親訪友'
            when 7 then '其他'
            else '未知'
        end                             as primary_purpose,

        -- ── 滿意度與回訪意願 ──────────────────────────────
        overall_satisfaction,
        case overall_satisfaction
            when 1 then '非常不滿意'
            when 2 then '不滿意'
            when 3 then '普通'
            when 4 then '滿意'
            when 5 then '非常滿意'
            else '未知'
        end                             as satisfaction_label,

        would_revisit,
        would_recommend

    from base

)

select * from decoded
