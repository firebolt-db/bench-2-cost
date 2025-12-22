### Cost Comparison: ClickHouse Cloud (AWS) vs Firebolt Cloud

#### Configuration

| Metric | ClickHouse Cloud (AWS) | Firebolt Cloud |
|--------|------------------------|----------------|
| Cluster Size | 3 | 3 |
| Machine/Engine | 236GiB | L_COMPUTE_OPTIMIZED |
| Data Size (GB) | 95.66 | 63.56 |

#### Performance (Best of 3 runs, 43/43 queries)

| Metric | ClickHouse Cloud (AWS) | Firebolt Cloud |
|--------|------------------------|----------------|
| Total Query Time | 208.679s | 120.382s |
| Queries Won | 7 | 36 |

---

#### Storage Cost (Monthly)

| System | Cost |
|--------|------|
| ClickHouse Cloud (AWS) | $2.4201 |
| Firebolt Cloud | $1.5648 |
| **Savings** | **Firebolt Cloud saves 35.3%** |

---

#### Compute Cost - Enterprise Tier (43 queries)

| System | Cost |
|--------|------|
| ClickHouse Cloud (AWS) (Enterprise) | $2.002249 |
| Firebolt Cloud (Enterprise) | $0.481528 |
| **Savings** | **Firebolt Cloud saves 76.0%** |

---

#### Compute Cost - Basic/Standard Tier (43 queries)

| System | Cost |
|--------|------|
| ClickHouse Cloud (AWS) (Basic) | $1.118910 |
| Firebolt Cloud (Standard) | $0.369171 |
| **Savings** | **Firebolt Cloud saves 67.0%** |

---

#### Compute Cost - Scale/Standard Tier (43 queries)

| System | Cost |
|--------|------|
| ClickHouse Cloud (AWS) (Scale) | $1.531107 |
| Firebolt Cloud (Standard) | $0.369171 |
| **Savings** | **Firebolt Cloud saves 75.9%** |

---

#### Summary

| Category | Winner | Savings |
|----------|--------|---------|
| Storage | Firebolt Cloud | 35.3% |
| Compute (Enterprise) | Firebolt Cloud | 76.0% |
| Compute (Basic/Standard) | Firebolt Cloud | 67.0% |
| Compute (Scale/Standard) | Firebolt Cloud | 75.9% |
| Query Performance | Firebolt Cloud | 42.3% faster |

---

#### Query Details

| ClickHouse Node | Firebolt Node | Cluster Size | Scan Cache | Query | ClickHouse Best | Firebolt Best |
|---|---|---|---|---|---|---|
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q1 | 0.002 | 0.008 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q2 | 0.273 | 0.246 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q3 | 1.122 | 0.503 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q4 | 0.961 | 0.435 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q5 | 1.618 | 1.038 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q6 | 2.681 | 2.687 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q7 | 0.854 | 0.322 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q8 | 0.758 | 0.211 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q9 | 2.495 | 5.100 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q10 | 3.377 | 3.149 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q11 | 1.227 | 1.135 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q12 | 1.881 | 1.211 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q13 | 2.803 | 1.752 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q14 | 3.281 | 9.751 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q15 | 3.161 | 1.936 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q16 | 1.848 | 0.949 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q17 | 5.831 | 3.562 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q18 | 5.473 | 3.538 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q19 | 7.889 | 4.888 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q20 | 0.121 | 0.040 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q21 | 4.152 | 4.797 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q22 | 4.489 | 4.446 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q23 | 14.848 | 4.696 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q24 | 13.253 | 4.598 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q25 | 2.326 | 1.478 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q26 | 1.699 | 2.012 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q27 | 2.323 | 1.456 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q28 | 5.776 | 6.859 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q29 | 66.064 | 20.471 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q30 | 0.957 | 0.246 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q31 | 3.058 | 2.409 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q32 | 6.457 | 2.600 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q33 | 9.257 | 4.277 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q34 | 11.956 | 7.874 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q35 | 11.297 | 7.925 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q36 | 1.847 | 0.873 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q37 | 0.241 | 0.154 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q38 | 0.153 | 0.122 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q39 | 0.128 | 0.107 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q40 | 0.373 | 0.332 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q41 | 0.182 | 0.061 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q42 | 0.105 | 0.066 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q43 | 0.082 | 0.062 |
