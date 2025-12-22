### Cost Comparison: ClickHouse Cloud (AWS) vs Firebolt Cloud

#### Configuration

| Metric | ClickHouse Cloud (AWS) | Firebolt Cloud |
|--------|------------------------|----------------|
| Cluster Size | 3 | 3 |
| Machine/Engine | 236GiB | L_COMPUTE_OPTIMIZED |
| Data Size (GB) | 182.28 | 392.74 |

#### Performance (Best of 3 runs, 43/43 queries)

| Metric | ClickHouse Cloud (AWS) | Firebolt Cloud |
|--------|------------------------|----------------|
| Total Query Time | 1157.477s | 1063.461s |
| Queries Won | 33 | 10 |

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
| ClickHouse Cloud (AWS) (Enterprise) | $11.105847 |
| Firebolt Cloud (Enterprise) | $4.253844 |
| **Savings** | **Firebolt Cloud saves 61.7%** |

---

#### Compute Cost - Basic/Standard Tier (43 queries)

| System | Cost |
|--------|------|
| ClickHouse Cloud (AWS) (Basic) | $6.206242 |
| Firebolt Cloud (Standard) | $3.261280 |
| **Savings** | **Firebolt Cloud saves 47.5%** |

---

#### Compute Cost - Scale/Standard Tier (43 queries)

| System | Cost |
|--------|------|
| ClickHouse Cloud (AWS) (Scale) | $8.492573 |
| Firebolt Cloud (Standard) | $3.261280 |
| **Savings** | **Firebolt Cloud saves 61.6%** |

---

#### Summary

| Category | Winner | Savings |
|----------|--------|---------|
| Storage | ClickHouse Cloud (AWS) | 52.3% |
| Compute (Enterprise) | Firebolt Cloud | 61.7% |
| Compute (Basic/Standard) | Firebolt Cloud | 47.5% |
| Compute (Scale/Standard) | Firebolt Cloud | 61.6% |
| Query Performance | Firebolt Cloud | 8.1% faster |

---

#### Query Details

| ClickHouse Node | Firebolt Node | Cluster Size | Scan Cache | Query | ClickHouse Best | Firebolt Best |
|---|---|---|---|---|---|---|
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q1 | 0.002 | 0.007 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q2 | 0.745 | 1.714 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q3 | 1.840 | 4.653 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q4 | 3.379 | 4.058 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q5 | 4.232 | 13.113 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q6 | 14.896 | 25.414 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q7 | 1.254 | 2.965 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q8 | 1.120 | 1.743 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q9 | 7.566 | 59.792 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q10 | 11.594 | 27.784 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q11 | 5.460 | 8.730 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q12 | 7.243 | 9.369 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q13 | 11.555 | 15.099 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q14 | 14.133 | 66.043 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q15 | 13.073 | 16.724 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q16 | 5.868 | 7.601 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q17 | 26.956 | 32.849 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q18 | 25.229 | 32.794 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q19 | 35.193 | 43.773 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q20 | 2.683 | 0.087 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q21 | 37.814 | 46.304 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q22 | 29.172 | 42.679 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q23 | 40.429 | 43.447 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q24 | 51.045 | 44.605 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q25 | 9.209 | 12.327 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q26 | 9.157 | 16.414 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q27 | 9.477 | 13.093 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q28 | 43.250 | 62.671 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q29 | 527.601 | 190.752 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q30 | 1.193 | 2.172 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q31 | 15.571 | 17.954 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q32 | 17.798 | 18.804 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q33 | 24.445 | 27.273 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q34 | 56.388 | 68.519 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q35 | 55.983 | 69.313 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q36 | 4.303 | 7.016 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q37 | 3.834 | 1.035 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q38 | 1.208 | 0.794 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q39 | 4.450 | 0.680 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q40 | 16.265 | 2.514 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q41 | 0.914 | 0.250 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q42 | 1.268 | 0.258 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q43 | 2.682 | 0.275 |
