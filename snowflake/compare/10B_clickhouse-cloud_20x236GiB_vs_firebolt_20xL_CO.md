### Cost Comparison: ClickHouse Cloud (AWS) vs Firebolt Cloud

#### Configuration

| Metric | ClickHouse Cloud (AWS) | Firebolt Cloud |
|--------|------------------------|----------------|
| Cluster Size | 20 | 20 |
| Machine/Engine | 236GiB | L_COMPUTE_OPTIMIZED |
| Data Size (GB) | 95.66 | 63.56 |

#### Performance (Best of 3 runs, 43/43 queries)

| Metric | ClickHouse Cloud (AWS) | Firebolt Cloud |
|--------|------------------------|----------------|
| Total Query Time | 66.699s | 22.398s |
| Queries Won | 4 | 39 |

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
| ClickHouse Cloud (AWS) (Enterprise) | $4.266457 |
| Firebolt Cloud (Enterprise) | $0.597280 |
| **Savings** | **Firebolt Cloud saves 86.0%** |

---

#### Compute Cost - Basic/Standard Tier (43 queries)

| System | Cost |
|--------|------|
| ClickHouse Cloud (AWS) (Basic) | $2.384209 |
| Firebolt Cloud (Standard) | $0.457915 |
| **Savings** | **Firebolt Cloud saves 80.8%** |

---

#### Compute Cost - Scale/Standard Tier (43 queries)

| System | Cost |
|--------|------|
| ClickHouse Cloud (AWS) (Scale) | $3.262533 |
| Firebolt Cloud (Standard) | $0.457915 |
| **Savings** | **Firebolt Cloud saves 86.0%** |

---

#### Summary

| Category | Winner | Savings |
|----------|--------|---------|
| Storage | Firebolt Cloud | 35.3% |
| Compute (Enterprise) | Firebolt Cloud | 86.0% |
| Compute (Basic/Standard) | Firebolt Cloud | 80.8% |
| Compute (Scale/Standard) | Firebolt Cloud | 86.0% |
| Query Performance | Firebolt Cloud | 66.4% faster |

---

#### Query Details

| ClickHouse Node | Firebolt Node | Cluster Size | Scan Cache | Query | ClickHouse Best | Firebolt Best | Firebolt Query Label |
|---|---|---|---|---|---|---|---|
| 236GiB | L_COMPUTE_OPTIMIZED | 20 | False | Q1 | 0.002 | 0.015 | {"benchmark":"clickbench","volume":"10B","query":"q01","attempt":2} |
| 236GiB | L_COMPUTE_OPTIMIZED | 20 | False | Q2 | 0.294 | 0.079 | {"benchmark":"clickbench","volume":"10B","query":"q02","attempt":2} |
| 236GiB | L_COMPUTE_OPTIMIZED | 20 | False | Q3 | 0.355 | 0.123 | {"benchmark":"clickbench","volume":"10B","query":"q03","attempt":3} |
| 236GiB | L_COMPUTE_OPTIMIZED | 20 | False | Q4 | 0.305 | 0.116 | {"benchmark":"clickbench","volume":"10B","query":"q04","attempt":3} |
| 236GiB | L_COMPUTE_OPTIMIZED | 20 | False | Q5 | 0.661 | 0.186 | {"benchmark":"clickbench","volume":"10B","query":"q05","attempt":2} |
| 236GiB | L_COMPUTE_OPTIMIZED | 20 | False | Q6 | 0.675 | 0.535 | {"benchmark":"clickbench","volume":"10B","query":"q06","attempt":3} |
| 236GiB | L_COMPUTE_OPTIMIZED | 20 | False | Q7 | 0.298 | 0.086 | {"benchmark":"clickbench","volume":"10B","query":"q07","attempt":2} |
| 236GiB | L_COMPUTE_OPTIMIZED | 20 | False | Q8 | 0.297 | 0.080 | {"benchmark":"clickbench","volume":"10B","query":"q08","attempt":3} |
| 236GiB | L_COMPUTE_OPTIMIZED | 20 | False | Q9 | 0.873 | 0.249 | {"benchmark":"clickbench","volume":"10B","query":"q09","attempt":2} |
| 236GiB | L_COMPUTE_OPTIMIZED | 20 | False | Q10 | 0.998 | 0.698 | {"benchmark":"clickbench","volume":"10B","query":"q10","attempt":2} |
| 236GiB | L_COMPUTE_OPTIMIZED | 20 | False | Q11 | 0.526 | 0.244 | {"benchmark":"clickbench","volume":"10B","query":"q11","attempt":2} |
| 236GiB | L_COMPUTE_OPTIMIZED | 20 | False | Q12 | 0.562 | 0.274 | {"benchmark":"clickbench","volume":"10B","query":"q12","attempt":2} |
| 236GiB | L_COMPUTE_OPTIMIZED | 20 | False | Q13 | 1.024 | 0.378 | {"benchmark":"clickbench","volume":"10B","query":"q13","attempt":2} |
| 236GiB | L_COMPUTE_OPTIMIZED | 20 | False | Q14 | 1.579 | 0.662 | {"benchmark":"clickbench","volume":"10B","query":"q14","attempt":2} |
| 236GiB | L_COMPUTE_OPTIMIZED | 20 | False | Q15 | 1.079 | 0.421 | {"benchmark":"clickbench","volume":"10B","query":"q15","attempt":2} |
| 236GiB | L_COMPUTE_OPTIMIZED | 20 | False | Q16 | 0.672 | 0.216 | {"benchmark":"clickbench","volume":"10B","query":"q16","attempt":2} |
| 236GiB | L_COMPUTE_OPTIMIZED | 20 | False | Q17 | 2.236 | 0.744 | {"benchmark":"clickbench","volume":"10B","query":"q17","attempt":3} |
| 236GiB | L_COMPUTE_OPTIMIZED | 20 | False | Q18 | 1.757 | 0.705 | {"benchmark":"clickbench","volume":"10B","query":"q18","attempt":2} |
| 236GiB | L_COMPUTE_OPTIMIZED | 20 | False | Q19 | 3.623 | 0.950 | {"benchmark":"clickbench","volume":"10B","query":"q19","attempt":2} |
| 236GiB | L_COMPUTE_OPTIMIZED | 20 | False | Q20 | 0.120 | 0.038 | {"benchmark":"clickbench","volume":"10B","query":"q20","attempt":3} |
| 236GiB | L_COMPUTE_OPTIMIZED | 20 | False | Q21 | 0.882 | 0.948 | {"benchmark":"clickbench","volume":"10B","query":"q21","attempt":3} |
| 236GiB | L_COMPUTE_OPTIMIZED | 20 | False | Q22 | 0.455 | 0.909 | {"benchmark":"clickbench","volume":"10B","query":"q22","attempt":3} |
| 236GiB | L_COMPUTE_OPTIMIZED | 20 | False | Q23 | 2.076 | 0.872 | {"benchmark":"clickbench","volume":"10B","query":"q23","attempt":2} |
| 236GiB | L_COMPUTE_OPTIMIZED | 20 | False | Q24 | 10.854 | 0.983 | {"benchmark":"clickbench","volume":"10B","query":"q24","attempt":3} |
| 236GiB | L_COMPUTE_OPTIMIZED | 20 | False | Q25 | 0.613 | 0.285 | {"benchmark":"clickbench","volume":"10B","query":"q25","attempt":3} |
| 236GiB | L_COMPUTE_OPTIMIZED | 20 | False | Q26 | 0.393 | 0.387 | {"benchmark":"clickbench","volume":"10B","query":"q26","attempt":3} |
| 236GiB | L_COMPUTE_OPTIMIZED | 20 | False | Q27 | 0.608 | 0.282 | {"benchmark":"clickbench","volume":"10B","query":"q27","attempt":3} |
| 236GiB | L_COMPUTE_OPTIMIZED | 20 | False | Q28 | 1.142 | 1.308 | {"benchmark":"clickbench","volume":"10B","query":"q28","attempt":2} |
| 236GiB | L_COMPUTE_OPTIMIZED | 20 | False | Q29 | 12.608 | 3.643 | {"benchmark":"clickbench","volume":"10B","query":"q29","attempt":2} |
| 236GiB | L_COMPUTE_OPTIMIZED | 20 | False | Q30 | 0.339 | 0.079 | {"benchmark":"clickbench","volume":"10B","query":"q30","attempt":3} |
| 236GiB | L_COMPUTE_OPTIMIZED | 20 | False | Q31 | 0.964 | 0.495 | {"benchmark":"clickbench","volume":"10B","query":"q31","attempt":3} |
| 236GiB | L_COMPUTE_OPTIMIZED | 20 | False | Q32 | 1.357 | 0.536 | {"benchmark":"clickbench","volume":"10B","query":"q32","attempt":3} |
| 236GiB | L_COMPUTE_OPTIMIZED | 20 | False | Q33 | 4.182 | 0.880 | {"benchmark":"clickbench","volume":"10B","query":"q33","attempt":3} |
| 236GiB | L_COMPUTE_OPTIMIZED | 20 | False | Q34 | 4.792 | 1.548 | {"benchmark":"clickbench","volume":"10B","query":"q34","attempt":3} |
| 236GiB | L_COMPUTE_OPTIMIZED | 20 | False | Q35 | 4.945 | 1.554 | {"benchmark":"clickbench","volume":"10B","query":"q35","attempt":2} |
| 236GiB | L_COMPUTE_OPTIMIZED | 20 | False | Q36 | 0.619 | 0.189 | {"benchmark":"clickbench","volume":"10B","query":"q36","attempt":2} |
| 236GiB | L_COMPUTE_OPTIMIZED | 20 | False | Q37 | 0.272 | 0.113 | {"benchmark":"clickbench","volume":"10B","query":"q37","attempt":3} |
| 236GiB | L_COMPUTE_OPTIMIZED | 20 | False | Q38 | 0.301 | 0.099 | {"benchmark":"clickbench","volume":"10B","query":"q38","attempt":2} |
| 236GiB | L_COMPUTE_OPTIMIZED | 20 | False | Q39 | 0.241 | 0.092 | {"benchmark":"clickbench","volume":"10B","query":"q39","attempt":3} |
| 236GiB | L_COMPUTE_OPTIMIZED | 20 | False | Q40 | 0.740 | 0.198 | {"benchmark":"clickbench","volume":"10B","query":"q40","attempt":3} |
| 236GiB | L_COMPUTE_OPTIMIZED | 20 | False | Q41 | 0.119 | 0.066 | {"benchmark":"clickbench","volume":"10B","query":"q41","attempt":3} |
| 236GiB | L_COMPUTE_OPTIMIZED | 20 | False | Q42 | 0.139 | 0.066 | {"benchmark":"clickbench","volume":"10B","query":"q42","attempt":3} |
| 236GiB | L_COMPUTE_OPTIMIZED | 20 | False | Q43 | 0.122 | 0.067 | {"benchmark":"clickbench","volume":"10B","query":"q43","attempt":2} |
