### Cost Comparison: ClickHouse Cloud (AWS) vs Firebolt Cloud

#### Configuration

| Metric | ClickHouse Cloud (AWS) | Firebolt Cloud |
|--------|------------------------|----------------|
| Cluster Size | 3 | 1 |
| Machine/Engine | 236GiB | L_COMPUTE_OPTIMIZED |
| Data Size (GB) | 44.54 | 25.37 |

#### Performance (Best of 3 runs, 43/43 queries)

| Metric | ClickHouse Cloud (AWS) | Firebolt Cloud |
|--------|------------------------|----------------|
| Total Query Time | 38.451s | 37.508s |
| Queries Won | 21 | 22 |

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
| Firebolt Cloud (Enterprise) | $0.050011 |
| **Savings** | **Firebolt Cloud saves 86.4%** |

---

#### Compute Cost - Basic/Standard Tier (43 queries)

| System | Cost |
|--------|------|
| ClickHouse Cloud (AWS) (Basic) | $0.206169 |
| Firebolt Cloud (Standard) | $0.038342 |
| **Savings** | **Firebolt Cloud saves 81.4%** |

---

#### Compute Cost - Scale/Standard Tier (43 queries)

| System | Cost |
|--------|------|
| ClickHouse Cloud (AWS) (Scale) | $0.282120 |
| Firebolt Cloud (Standard) | $0.038342 |
| **Savings** | **Firebolt Cloud saves 86.4%** |

---

#### Summary

| Category | Winner | Savings |
|----------|--------|---------|
| Storage | Firebolt Cloud | 44.6% |
| Compute (Enterprise) | Firebolt Cloud | 86.4% |
| Compute (Basic/Standard) | Firebolt Cloud | 81.4% |
| Compute (Scale/Standard) | Firebolt Cloud | 86.4% |
| Query Performance | Firebolt Cloud | 2.5% faster |

---

#### Query Details

| ClickHouse Node | Firebolt Node | Cluster Size | Scan Cache | Query | ClickHouse Best | Firebolt Best | Firebolt Query Label |
|---|---|---|---|---|---|---|---|
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q1 | 0.002 | 0.006 | {"benchmark":"clickbench","volume":"1B","query":"q01","attempt":2} |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q2 | 0.025 | 0.078 | {"benchmark":"clickbench","volume":"1B","query":"q02","attempt":3} |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q3 | 0.045 | 0.170 | {"benchmark":"clickbench","volume":"1B","query":"q03","attempt":1} |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q4 | 0.070 | 0.155 | {"benchmark":"clickbench","volume":"1B","query":"q04","attempt":3} |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q5 | 0.525 | 0.404 | {"benchmark":"clickbench","volume":"1B","query":"q05","attempt":3} |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q6 | 0.544 | 0.880 | {"benchmark":"clickbench","volume":"1B","query":"q06","attempt":3} |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q7 | 0.031 | 0.103 | {"benchmark":"clickbench","volume":"1B","query":"q07","attempt":3} |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q8 | 0.032 | 0.073 | {"benchmark":"clickbench","volume":"1B","query":"q08","attempt":1} |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q9 | 0.762 | 0.507 | {"benchmark":"clickbench","volume":"1B","query":"q09","attempt":1} |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q10 | 0.870 | 1.146 | {"benchmark":"clickbench","volume":"1B","query":"q10","attempt":3} |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q11 | 0.264 | 0.371 | {"benchmark":"clickbench","volume":"1B","query":"q11","attempt":1} |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q12 | 0.305 | 0.438 | {"benchmark":"clickbench","volume":"1B","query":"q12","attempt":3} |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q13 | 0.744 | 0.601 | {"benchmark":"clickbench","volume":"1B","query":"q13","attempt":2} |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q14 | 1.119 | 0.792 | {"benchmark":"clickbench","volume":"1B","query":"q14","attempt":2} |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q15 | 0.835 | 0.681 | {"benchmark":"clickbench","volume":"1B","query":"q15","attempt":1} |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q16 | 0.542 | 0.455 | {"benchmark":"clickbench","volume":"1B","query":"q16","attempt":1} |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q17 | 1.593 | 1.242 | {"benchmark":"clickbench","volume":"1B","query":"q17","attempt":2} |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q18 | 1.358 | 1.197 | {"benchmark":"clickbench","volume":"1B","query":"q18","attempt":3} |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q19 | 2.743 | 1.853 | {"benchmark":"clickbench","volume":"1B","query":"q19","attempt":2} |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q20 | 0.029 | 0.028 | {"benchmark":"clickbench","volume":"1B","query":"q20","attempt":1} |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q21 | 0.302 | 1.486 | {"benchmark":"clickbench","volume":"1B","query":"q21","attempt":2} |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q22 | 0.086 | 1.404 | {"benchmark":"clickbench","volume":"1B","query":"q22","attempt":3} |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q23 | 0.411 | 1.752 | {"benchmark":"clickbench","volume":"1B","query":"q23","attempt":2} |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q24 | 0.462 | 1.468 | {"benchmark":"clickbench","volume":"1B","query":"q24","attempt":2} |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q25 | 0.309 | 0.589 | {"benchmark":"clickbench","volume":"1B","query":"q25","attempt":3} |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q26 | 0.233 | 0.793 | {"benchmark":"clickbench","volume":"1B","query":"q26","attempt":3} |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q27 | 0.294 | 0.513 | {"benchmark":"clickbench","volume":"1B","query":"q27","attempt":3} |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q28 | 0.801 | 2.177 | {"benchmark":"clickbench","volume":"1B","query":"q28","attempt":2} |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q29 | 7.300 | 6.387 | {"benchmark":"clickbench","volume":"1B","query":"q29","attempt":1} |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q30 | 0.080 | 0.095 | {"benchmark":"clickbench","volume":"1B","query":"q30","attempt":2} |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q31 | 0.676 | 0.904 | {"benchmark":"clickbench","volume":"1B","query":"q31","attempt":1} |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q32 | 1.148 | 0.978 | {"benchmark":"clickbench","volume":"1B","query":"q32","attempt":1} |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q33 | 3.742 | 1.690 | {"benchmark":"clickbench","volume":"1B","query":"q33","attempt":2} |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q34 | 4.402 | 2.605 | {"benchmark":"clickbench","volume":"1B","query":"q34","attempt":3} |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q35 | 4.441 | 2.616 | {"benchmark":"clickbench","volume":"1B","query":"q35","attempt":2} |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q36 | 0.263 | 0.485 | {"benchmark":"clickbench","volume":"1B","query":"q36","attempt":3} |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q37 | 0.090 | 0.064 | {"benchmark":"clickbench","volume":"1B","query":"q37","attempt":2} |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q38 | 0.073 | 0.057 | {"benchmark":"clickbench","volume":"1B","query":"q38","attempt":2} |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q39 | 0.170 | 0.048 | {"benchmark":"clickbench","volume":"1B","query":"q39","attempt":2} |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q40 | 0.524 | 0.127 | {"benchmark":"clickbench","volume":"1B","query":"q40","attempt":3} |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q41 | 0.073 | 0.030 | {"benchmark":"clickbench","volume":"1B","query":"q41","attempt":2} |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q42 | 0.056 | 0.031 | {"benchmark":"clickbench","volume":"1B","query":"q42","attempt":3} |
| 236GiB | L_COMPUTE_OPTIMIZED | 3 | False | Q43 | 0.077 | 0.029 | {"benchmark":"clickbench","volume":"1B","query":"q43","attempt":1} |
