### Cost Comparison: ClickHouse Cloud (AWS) vs Firebolt Cloud

#### Configuration

| Metric | ClickHouse Cloud (AWS) | Firebolt Cloud |
|--------|------------------------|----------------|
| Cluster Size | 9 | 9 |
| Machine/Engine | 236GiB | L_COMPUTE_OPTIMIZED |
| Data Size (GB) | 182.28 | 392.74 |

#### Performance (Best of 3 runs, 43/43 queries)

| Metric | ClickHouse Cloud (AWS) | Firebolt Cloud |
|--------|------------------------|----------------|
| Total Query Time | 443.231s | 331.432s |
| Queries Won | 24 | 19 |

---

#### Storage Cost (Monthly)

| System | Cost |
|--------|------|
| ClickHouse Cloud (AWS) | $4.6118 |
| Firebolt Cloud | $9.6693 |
| **Savings** | **ClickHouse Cloud (AWS) saves 52.3%** |

---

#### Compute Cost - Enterprise Tier (43 queries)

| System | Cost |
|--------|------|
| ClickHouse Cloud (AWS) (Enterprise) | $12.758238 |
| Firebolt Cloud (Enterprise) | $3.977184 |
| **Savings** | **Firebolt Cloud saves 68.8%** |

---

#### Compute Cost - Basic/Standard Tier (43 queries)

| System | Cost |
|--------|------|
| ClickHouse Cloud (AWS) (Basic) | $7.129642 |
| Firebolt Cloud (Standard) | $3.049174 |
| **Savings** | **Firebolt Cloud saves 57.2%** |

---

#### Compute Cost - Scale/Standard Tier (43 queries)

| System | Cost |
|--------|------|
| ClickHouse Cloud (AWS) (Scale) | $9.756146 |
| Firebolt Cloud (Standard) | $3.049174 |
| **Savings** | **Firebolt Cloud saves 68.7%** |

---

#### Summary

| Category | Winner | Savings |
|----------|--------|---------|
| Storage | ClickHouse Cloud (AWS) | 52.3% |
| Compute (Enterprise) | Firebolt Cloud | 68.8% |
| Compute (Basic/Standard) | Firebolt Cloud | 57.2% |
| Compute (Scale/Standard) | Firebolt Cloud | 68.7% |
| Query Performance | Firebolt Cloud | 25.2% faster |

---

#### Query Details

| ClickHouse Node | Firebolt Node | Cluster Size | Scan Cache | Query | ClickHouse Best | Firebolt Best |
|---|---|---|---|---|---|---|
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q1 | 0.002 | 0.009 |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q2 | 0.437 | 0.603 |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q3 | 0.468 | 1.578 |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q4 | 0.808 | 1.375 |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q5 | 1.576 | 1.864 |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q6 | 5.080 | 8.582 |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q7 | 0.389 | 1.011 |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q8 | 0.683 | 0.622 |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q9 | 2.869 | 2.741 |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q10 | 4.276 | 9.359 |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q11 | 2.536 | 2.968 |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q12 | 3.012 | 3.190 |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q13 | 4.502 | 5.226 |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q14 | 9.028 | 5.765 |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q15 | 10.139 | 5.598 |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q16 | 2.147 | 2.541 |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q17 | 9.923 | 10.922 |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q18 | 9.106 | 10.895 |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q19 | 12.261 | 14.455 |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q20 | 0.651 | 0.048 |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q21 | 10.680 | 17.919 |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q22 | 7.741 | 15.989 |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q23 | 14.594 | 15.217 |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q24 | 16.395 | 15.591 |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q25 | 4.903 | 4.244 |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q26 | 3.477 | 5.754 |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q27 | 5.453 | 4.477 |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q28 | 13.926 | 22.119 |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q29 | 198.977 | 64.558 |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q30 | 0.423 | 0.756 |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q31 | 7.241 | 6.192 |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q32 | 9.216 | 6.451 |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q33 | 9.978 | 9.198 |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q34 | 21.518 | 24.033 |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q35 | 22.843 | 24.047 |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q36 | 1.830 | 2.341 |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q37 | 0.748 | 0.563 |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q38 | 0.519 | 0.443 |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q39 | 2.177 | 0.381 |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q40 | 7.987 | 1.299 |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q41 | 0.693 | 0.159 |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q42 | 0.625 | 0.171 |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q43 | 1.394 | 0.178 |
