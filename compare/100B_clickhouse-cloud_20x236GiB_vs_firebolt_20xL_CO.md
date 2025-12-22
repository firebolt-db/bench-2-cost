### Cost Comparison: ClickHouse Cloud (AWS) vs Firebolt Cloud

#### Configuration

| Metric | ClickHouse Cloud (AWS) | Firebolt Cloud |
|--------|------------------------|----------------|
| Cluster Size | 20 | 20 |
| Machine/Engine | 236GiB | L_COMPUTE_OPTIMIZED |
| Data Size (GB) | 182.28 | 392.74 |

#### Performance (Best of 3 runs, 43/43 queries)

| Metric | ClickHouse Cloud (AWS) | Firebolt Cloud |
|--------|------------------------|----------------|
| Total Query Time | 275.422s | 156.106s |
| Queries Won | 13 | 30 |

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
| ClickHouse Cloud (AWS) (Enterprise) | $17.617598 |
| Firebolt Cloud (Enterprise) | $4.162827 |
| **Savings** | **Firebolt Cloud saves 76.4%** |

---

#### Compute Cost - Basic/Standard Tier (43 queries)

| System | Cost |
|--------|------|
| ClickHouse Cloud (AWS) (Basic) | $9.845181 |
| Firebolt Cloud (Standard) | $3.191500 |
| **Savings** | **Firebolt Cloud saves 67.6%** |

---

#### Compute Cost - Scale/Standard Tier (43 queries)

| System | Cost |
|--------|------|
| ClickHouse Cloud (AWS) (Scale) | $13.472068 |
| Firebolt Cloud (Standard) | $3.191500 |
| **Savings** | **Firebolt Cloud saves 76.3%** |

---

#### Summary

| Category | Winner | Savings |
|----------|--------|---------|
| Storage | ClickHouse Cloud (AWS) | 52.3% |
| Compute (Enterprise) | Firebolt Cloud | 76.4% |
| Compute (Basic/Standard) | Firebolt Cloud | 67.6% |
| Compute (Scale/Standard) | Firebolt Cloud | 76.3% |
| Query Performance | Firebolt Cloud | 43.3% faster |

---

#### Query Details

| ClickHouse Node | Firebolt Node | Cluster Size | Scan Cache | Query | ClickHouse Best | Firebolt Best |
|---|---|---|---|---|---|---|
| 236GiB | L_COMPUTE_OPTIMIZED | 20 | False | Q1 | 0.002 | 0.007 |
| 236GiB | L_COMPUTE_OPTIMIZED | 20 | False | Q2 | 0.425 | 0.299 |
| 236GiB | L_COMPUTE_OPTIMIZED | 20 | False | Q3 | 0.296 | 0.755 |
| 236GiB | L_COMPUTE_OPTIMIZED | 20 | False | Q4 | 0.477 | 0.657 |
| 236GiB | L_COMPUTE_OPTIMIZED | 20 | False | Q5 | 1.003 | 0.894 |
| 236GiB | L_COMPUTE_OPTIMIZED | 20 | False | Q6 | 3.550 | 4.042 |
| 236GiB | L_COMPUTE_OPTIMIZED | 20 | False | Q7 | 0.189 | 0.487 |
| 236GiB | L_COMPUTE_OPTIMIZED | 20 | False | Q8 | 0.601 | 0.317 |
| 236GiB | L_COMPUTE_OPTIMIZED | 20 | False | Q9 | 1.775 | 1.323 |
| 236GiB | L_COMPUTE_OPTIMIZED | 20 | False | Q10 | 3.089 | 4.482 |
| 236GiB | L_COMPUTE_OPTIMIZED | 20 | False | Q11 | 2.263 | 1.413 |
| 236GiB | L_COMPUTE_OPTIMIZED | 20 | False | Q12 | 2.743 | 1.521 |
| 236GiB | L_COMPUTE_OPTIMIZED | 20 | False | Q13 | 3.283 | 2.512 |
| 236GiB | L_COMPUTE_OPTIMIZED | 20 | False | Q14 | 8.266 | 2.779 |
| 236GiB | L_COMPUTE_OPTIMIZED | 20 | False | Q15 | 6.651 | 2.673 |
| 236GiB | L_COMPUTE_OPTIMIZED | 20 | False | Q16 | 1.400 | 1.222 |
| 236GiB | L_COMPUTE_OPTIMIZED | 20 | False | Q17 | 7.319 | 5.158 |
| 236GiB | L_COMPUTE_OPTIMIZED | 20 | False | Q18 | 6.392 | 5.163 |
| 236GiB | L_COMPUTE_OPTIMIZED | 20 | False | Q19 | 8.895 | 6.839 |
| 236GiB | L_COMPUTE_OPTIMIZED | 20 | False | Q20 | 0.652 | 0.046 |
| 236GiB | L_COMPUTE_OPTIMIZED | 20 | False | Q21 | 5.014 | 7.604 |
| 236GiB | L_COMPUTE_OPTIMIZED | 20 | False | Q22 | 2.772 | 7.104 |
| 236GiB | L_COMPUTE_OPTIMIZED | 20 | False | Q23 | 5.865 | 7.052 |
| 236GiB | L_COMPUTE_OPTIMIZED | 20 | False | Q24 | 12.037 | 7.399 |
| 236GiB | L_COMPUTE_OPTIMIZED | 20 | False | Q25 | 5.020 | 2.004 |
| 236GiB | L_COMPUTE_OPTIMIZED | 20 | False | Q26 | 2.007 | 2.683 |
| 236GiB | L_COMPUTE_OPTIMIZED | 20 | False | Q27 | 5.009 | 2.120 |
| 236GiB | L_COMPUTE_OPTIMIZED | 20 | False | Q28 | 8.054 | 10.210 |
| 236GiB | L_COMPUTE_OPTIMIZED | 20 | False | Q29 | 108.989 | 30.274 |
| 236GiB | L_COMPUTE_OPTIMIZED | 20 | False | Q30 | 0.245 | 0.376 |
| 236GiB | L_COMPUTE_OPTIMIZED | 20 | False | Q31 | 7.036 | 3.081 |
| 236GiB | L_COMPUTE_OPTIMIZED | 20 | False | Q32 | 7.601 | 3.173 |
| 236GiB | L_COMPUTE_OPTIMIZED | 20 | False | Q33 | 8.897 | 4.431 |
| 236GiB | L_COMPUTE_OPTIMIZED | 20 | False | Q34 | 13.236 | 11.197 |
| 236GiB | L_COMPUTE_OPTIMIZED | 20 | False | Q35 | 13.596 | 11.444 |
| 236GiB | L_COMPUTE_OPTIMIZED | 20 | False | Q36 | 0.941 | 1.124 |
| 236GiB | L_COMPUTE_OPTIMIZED | 20 | False | Q37 | 0.548 | 0.385 |
| 236GiB | L_COMPUTE_OPTIMIZED | 20 | False | Q38 | 0.429 | 0.317 |
| 236GiB | L_COMPUTE_OPTIMIZED | 20 | False | Q39 | 1.281 | 0.273 |
| 236GiB | L_COMPUTE_OPTIMIZED | 20 | False | Q40 | 5.571 | 0.844 |
| 236GiB | L_COMPUTE_OPTIMIZED | 20 | False | Q41 | 0.549 | 0.140 |
| 236GiB | L_COMPUTE_OPTIMIZED | 20 | False | Q42 | 0.405 | 0.139 |
| 236GiB | L_COMPUTE_OPTIMIZED | 20 | False | Q43 | 1.049 | 0.143 |
