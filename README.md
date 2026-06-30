# 韓國旅客在台消費行為分析
 
## 專案簡介
以台灣觀光署「113年來臺旅客消費及動向調查」為資料來源，
針對韓國旅客（831 筆）建立端對端資料管線，
分析其在台消費金額分布、消費結構與人口統計交叉行為。
 
## 🔗 Dashboard
[查看互動式 Looker Studio Dashboard](https://datastudio.google.com/reporting/3d87d930-8b0c-4ebc-b7f3-d341308a16ea)
 
## 技術棧
- **資料儲存**：Google BigQuery
- **資料建模**：dbt Core
- **視覺化**：Looker Studio
- **版本控制**：GitHub
## 資料架構（Star Schema）
```
Raw CSV → BigQuery (raw) → dbt staging → dbt intermediate → dbt marts → Looker Studio
```
- Fact table：`fct_korean_tourist_spending`
- Dim tables：`dim_tourist`、`dim_trip`、`dim_spending_detail`
## 主要發現
- 韓國旅客平均消費 NT$20,875，中位數 NT$16,680
- 旅館、餐飲、購物三項合計佔總支出 77%
- 散客平均花費是團客的 2.5 倍
- 8-9 月為消費高峰，平均超過 NT$28,000
- 30-39 歲為消費力最強的年齡層
- 87% 旅客表示會再訪台灣，91% 願意推薦親友
## 專案結構
```
models/
├── staging/
│   ├── sources.yml              # BigQuery raw table 定義
│   ├── stg_korean_tourists.sql  # 篩選韓國旅客、欄位 rename
│   └── stg_spending.sql         # 幣別換算為台幣
├── intermediate/
│   ├── int_tourist_profile.sql  # 人口統計 code decode
│   ├── int_trip_behavior.sql    # 旅遊行為整合
│   └── int_spending_cleaned.sql # 離群值標記、人均日支出
├── marts/
│   ├── dim_tourist.sql
│   ├── dim_trip.sql
│   ├── dim_spending_detail.sql
│   └── fct_korean_tourist_spending.sql
└── schema.yml                   # 欄位說明與 dbt tests（60+ 個）
```
 
## 如何執行
```bash
dbt deps
dbt run
dbt test
dbt docs generate && dbt docs serve
```
 
## 資料來源
台灣觀光署「113年來臺旅客消費及動向調查」
https://admin.taiwan.net.tw