-- models/staging/stg_korean_tourists.sql
--
-- 職責：從原始資料篩出韓國旅客（nation = 3），
--       rename 欄位為易讀名稱，並標記幣別供下一層換算使用。
--       此層不做任何商業邏輯，只做 1:1 清洗。
--
-- Materialization：view（staging 標準做法，不佔 BigQuery storage）

{{ config(materialized='view') }}

with source as (

    select * from {{ source('taiwan_tourism', 'raw_tourist_survey_113') }}

),

korean_only as (

    -- 篩選韓國旅客：nation = 3（見問卷附件一）
    select * from source
    where nation = 3

),

renamed as (

    select

        -- ── 識別欄位 ──────────────────────────────────────
        id                              as tourist_id,
        mon                             as survey_month,

        -- ── 人口統計 ──────────────────────────────────────
        age                             as age_code,
        -- 1=12-19, 2=20-29, 3=30-39, 4=40-49,
        -- 5=50-59, 6=60-64, 7=65-69（無 8=70+ 出現在韓客資料中）

        gender                          as gender_code,
        -- 1=男, 2=女

        educ                            as education_code,
        -- 1=高中職以下, 2=大專, 3=碩博士

        income                          as income_code,
        -- 1=9,999以下 ... 7=100,000以上, 8=無固定收入（美元年收入）

        occup                           as occupation_code,
        -- 1~13，詳見問卷 E6

        -- ── 旅遊基本資訊 ──────────────────────────────────
        stay                            as stay_nights,
        freq                            as visit_frequency,
        plan                            as plan_days_ahead,
        purp1                           as primary_purpose_code,
        -- 1=觀光, 2=業務, 3=國際會議/展覽, 4=探親訪友, 7=其他
        type                            as travel_arrangement_code,
        -- 1=旅行社包辦團, 2=自訂行程旅行社包辦, 3=自訂+旅行社訂住宿
        -- 4=自訂+抵台後參加OTA, 5=完全自訂

        -- ── 住宿（複選，各自 0/1）────────────────────────
        slp1                            as stayed_hotel,
        slp2                            as stayed_bnb,
        slp3                            as stayed_relatives,

        -- ── 消費金額（原始幣別，待下一層換算）─────────────
        money                           as total_spend_raw,
        money1                          as hotel_spend_raw,
        money1_1                        as hotel_accommodation_raw,
        money2                          as food_outside_hotel_raw,
        money3                          as local_transport_raw,
        money4                          as entertainment_raw,
        money5                          as miscellaneous_raw,
        money6                          as shopping_raw,

        -- 購物細項
        m601                            as shopping_clothing_raw,
        m602                            as shopping_jewelry_raw,
        m603                            as shopping_souvenir_raw,
        m604                            as shopping_cosmetics_raw,
        m605                            as shopping_local_products_raw,
        m606                            as shopping_tobacco_alcohol_raw,
        m607                            as shopping_medicine_raw,
        m608                            as shopping_electronics_raw,
        m609                            as shopping_tea_raw,
        m610                            as shopping_other_raw,

        -- ── 幣別標記（供 stg_spending 換算用）─────────────
        dollar                          as currency_original,
        -- '新台幣' / '韓元' / '美元' / '日圓'

        -- ── 活動參與（複選，各自 0/1）────────────────────
        act3                            as did_festival,
        act5                            as did_massage,
        act7                            as did_exhibition,
        act9                            as did_historic_sites,
        act10                           as did_shopping,
        act11                           as did_nightmarket,
        act13                           as did_hiking,

        -- ── 交通工具（複選，各自 0/1）────────────────────
        t1                              as used_hsr,       -- 高鐵
        t2                              as used_tra,       -- 台鐵
        t3                              as used_mrt,       -- 捷運
        t6                              as used_taxi,      -- 計程車
        t11                             as used_uber,      -- Uber

        -- ── 滿意度 ────────────────────────────────────────
        sall                            as overall_satisfaction,
        -- 1=非常不滿意 ... 5=非常滿意

        again                           as would_revisit,
        -- 0=否, 1=是
        recom                           as would_recommend

    from korean_only

)

select * from renamed
