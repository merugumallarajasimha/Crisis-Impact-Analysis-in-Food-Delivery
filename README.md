# Crisis Impact Analysis in Food Delivery
# ⚡ QuickBite Express — Crisis Recovery Analysis
## 📌 Project Overview

QuickBite Express is a Bengaluru-based food-tech startup (founded 2020) that connects customers with nearby restaurants and cloud kitchens. In **June 2025**, the company faced a severe crisis triggered by a viral food safety incident at partner restaurants, combined with a week-long delivery outage during the monsoon season. Competitors (Swiggy, Zomato) capitalised aggressively, worsening the situation.

This project delivers a **5-page Power BI dashboard** providing end-to-end crisis analysis and recovery intelligence  covering order trends, revenue loss, operational failures, customer sentiment, loyalty churn, and competitor benchmarking  to guide QuickBite's turnaround strategy.

---

## 🎯 Business Problem

QuickBite's management needed answers to:
- How severe was the order and revenue decline during the crisis?
- Which cities, restaurants, and customer segments were worst affected?
- Did delivery performance and customer ratings collapse during the crisis?
- Which loyal customers churned — and which can be recovered?
- How does QuickBite's crisis compare to national competitors?

---

## 📊 Dashboard Structure (5 Pages)

| Page | Title | Questions Answered |
|------|-------|--------------------|
| 1 | Executive Overview | Q1 Monthly Orders · Q8 Revenue Impact |
| 2 | City & Restaurant Analysis | Q2 City Decline · Q3 Restaurant Decline · Q4 Cancellations |
| 3 | Operations, Ratings & Sentiment | Q5 Delivery SLA · Q6 Rating Trend · Q7 Sentiment Keywords |
| 4 | Revenue Impact & Customer Loyalty | Q8 Revenue Breakdown · Q9 Loyalty Churn · Q10 High-Value Customers |
| 5 | Secondary Analysis | S-Q1 Competitor Benchmarking · S-Q4 Restaurant Churn Risk · S-Q5 Lapsed Customer Recovery |

---

## 🔍 Key Findings

### Primary Analysis
- **Orders collapsed 61%** - Pre-crisis avg 22.7K/month dropped to 8.8K/month during crisis
- **₹26.7M revenue lost** - Crisis revenue (₹10.9M) was 70.9% below pre-crisis (₹37.6M)
- **Cancellation rate nearly doubled** - From 6.1% pre-crisis to 11.9% during crisis; Bengaluru and Kolkata most affected
- **Delivery SLA collapsed** - Avg delivery time jumped from 39.5 min to 60.1 min; SLA compliance fell from 43.6% to 12.2%
- **Rating crashed from 4.3★ to 2.5★** - Sharpest single-month drop between May and June 2025
- **Top negative keywords** in crisis reviews: quality, packaging, issue, safety, stale — signalling food safety as primary complaint
- **49 loyal customers stopped ordering** during the crisis; 26 of them had pre-crisis ratings above 4.5★ - highest-ROI recovery targets
- **Top 5% high-value customers** showed 4-6 order drops with severity clustering in Bengaluru; North Indian and Biryani cuisine segments most affected

### Secondary Analysis (Research-Based)
- **Competitors grew** during the same period  Zomato food delivery revenue +23.2% YoY (₹2,650 Cr); Swiggy revenue +54.4% YoY (₹5,561 Cr) — proving the crisis was QuickBite-specific, not industry-wide
- **Cloud kitchens and small brands** showed the highest churn risk (80–100% order decline); large dine-in chains were more resilient
- **High-priority lapsed customers** (Return Score 5–6/6) are identified for targeted recovery campaigns based on pre-crisis loyalty and satisfaction signals

---

## 🛠️ Tools & Technologies

| Tool | Usage |
|------|-------|
| **Power BI Desktop** | 5-page interactive dashboard · DAX measures · conditional formatting · word cloud visual |
| **SQL** | Data extraction · 15+ analytics tables · pre-crisis/crisis segmentation · customer loyalty scoring |
| **Excel** | Competitor data collection (Zomato/Swiggy Q2 FY26 filings) · return probability scoring · restaurant churn classification |
| **DAX** | Calculated columns (Severity · Return_Score · Return_Priority · Period) · custom KPI measures |

---

## 📐 DAX Measures Used

```dax
-- Monthly Active Customers
Monthly_Active_Customers = DISTINCTCOUNT(staging_orders[customer_id])

-- Revenue Decline %
Revenue_Decline_Pct = DIVIDE([Crisis_Revenue] - [Pre_Crisis_Revenue], [Pre_Crisis_Revenue]) * 100

-- Churn Risk Classification
Churn_Risk = IF([Order_Decline_Pct] <= -60, "High Risk",
             IF([Order_Decline_Pct] <= -30, "Medium Risk", "Low Risk"))

-- Return Probability Score
Return_Score = [Order_Score] + [Rating_Score]  -- max 6 points

-- SLA Compliance Rate
SLA_Compliance = DIVIDE(COUNTROWS(FILTER(orders, [delivery_min] <= 35)), COUNTROWS(orders))
```

---

## 📁 Dataset

- Source: **Codebasics Resume Challenge** (fictional dataset)
- Tables: `staging_orders` · `staging_customer` · `staging_restaurant` · `staging_delivery_performance` · `staging_ratings` · `staging_menu_item` + 10 analytics tables
- Period: **January 2025 -  September 2025**
- Records: ~149,166 orders · 20+ restaurant partners · multiple cities across India

---

## 💡 Business Recommendations

1. **Immediate:** Launch FSSAI food safety audit badge on app — low cost, highest trust impact
2. **Week 1:** Personalised cashback campaign targeting 26 high-rated churned loyal customers
3. **Month 1:** Restaurant verification program - prioritise Biryani and North Indian cloud kitchens showing >60% order decline
4. **Ongoing:** Monthly SLA compliance tracking - target recovery to pre-crisis 43.6% benchmark

---

## 📸 Dashboard Preview

> *Add screenshots of all 5 pages here after export*

---

## 🔗 References (Secondary Research)

- Zomato Q2 FY26 Results : [Business Standard](https://www.business-standard.com/companies/quarterly-results/eternal-q2-results-profit-65-cr-revenue-doubles-quick-commerce-growth-125101600845_1.html)
- Zomato Food Delivery Revenue : [Univest](https://univest.in/blogs/zomato-q2-results-2025)
- Swiggy Q2 FY26 Results : [Bajaj Broking](https://www.bajajbroking.in/blog/swiggy-q2-results-fy-25-26)
- Eternal Shareholder Letter : [Zomato IR](https://b.zmtcdn.com/investor-relations/Eternal_Shareholders_Letter_Q1FY26_Results.pdf)

---


