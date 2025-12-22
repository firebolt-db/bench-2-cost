### Cost Comparison: ClickHouse Cloud (AWS) vs Firebolt Cloud

#### Configuration

| Metric | ClickHouse Cloud (AWS) | Firebolt Cloud |
|--------|------------------------|----------------|
| Cluster Size | 3 | 3 |
| Machine/Engine | 236GiB | L_COMPUTE_OPTIMIZED |
| Data Size (GB) | 44.54 | 25.37 |

#### Performance (Best of 3 runs, 43/43 queries)

| Metric | ClickHouse Cloud (AWS) | Firebolt Cloud |
|--------|------------------------|----------------|
| Total Query Time | 38.451s | 20.923s |
| Queries Won | 14 | 29 |

---

#### Storage Cost (Monthly)

| System | Cost |
|--------|------|
| ClickHouse Cloud (AWS) | $1.1268 |
| Firebolt Cloud | $0.6245 |
| **Savings** | **Firebolt Cloud saves 44.6%** |

---

#### Compute Cost - Enterprise Tier (43 queries)

| System | Cost |
|--------|------|
| ClickHouse Cloud (AWS) (Enterprise) | $0.368933 |
| Firebolt Cloud (Enterprise) | $0.083692 |
| **Savings** | **Firebolt Cloud saves 77.3%** |

---

#### Compute Cost - Basic/Standard Tier (43 queries)

| System | Cost |
|--------|------|
| ClickHouse Cloud (AWS) (Basic) | $0.206169 |
| Firebolt Cloud (Standard) | $0.064164 |
| **Savings** | **Firebolt Cloud saves 68.9%** |

---

#### Compute Cost - Scale/Standard Tier (43 queries)

| System | Cost |
|--------|------|
| ClickHouse Cloud (AWS) (Scale) | $0.282120 |
| Firebolt Cloud (Standard) | $0.064164 |
| **Savings** | **Firebolt Cloud saves 77.3%** |

---

#### Summary

| Category | Winner | Savings |
|----------|--------|---------|
| Storage | Firebolt Cloud | 44.6% |
| Compute (Enterprise) | Firebolt Cloud | 77.3% |
| Compute (Basic/Standard) | Firebolt Cloud | 68.9% |
| Compute (Scale/Standard) | Firebolt Cloud | 77.3% |
| Query Performance | Firebolt Cloud | 45.6% faster |

---

#### Query Details

| ClickHouse Node | Firebolt Node | Cluster Size | Scan Cache | Query | ClickHouse Best | Firebolt Best |
|---|---|---|---|---|---|---|
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q1 | 0.002 | 0.010 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q2 | 0.025 | 0.060 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q3 | 0.045 | 0.092 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q4 | 0.070 | 0.086 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q5 | 0.525 | 0.267 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q6 | 0.544 | 0.427 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q7 | 0.031 | 0.058 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q8 | 0.032 | 0.047 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q9 | 0.762 | 0.671 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q10 | 0.870 | 0.624 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q11 | 0.264 | 0.165 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q12 | 0.305 | 0.195 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q13 | 0.744 | 0.344 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q14 | 1.119 | 1.438 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q15 | 0.835 | 0.379 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q16 | 0.542 | 0.260 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q17 | 1.593 | 0.680 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q18 | 1.358 | 0.649 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q19 | 2.743 | 1.094 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q20 | 0.029 | 0.037 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q21 | 0.302 | 0.583 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q22 | 0.086 | 0.586 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q23 | 0.411 | 0.762 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q24 | 0.462 | 0.610 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q25 | 0.309 | 0.243 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q26 | 0.233 | 0.333 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q27 | 0.294 | 0.208 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q28 | 0.801 | 0.861 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q29 | 7.300 | 2.546 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q30 | 0.080 | 0.064 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q31 | 0.676 | 0.428 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q32 | 1.148 | 0.534 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q33 | 3.742 | 1.659 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q34 | 4.402 | 1.643 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q35 | 4.441 | 1.647 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q36 | 0.263 | 0.209 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q37 | 0.090 | 0.072 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q38 | 0.073 | 0.054 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q39 | 0.170 | 0.058 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q40 | 0.524 | 0.115 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q41 | 0.073 | 0.039 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q42 | 0.056 | 0.044 |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q43 | 0.077 | 0.042 |
