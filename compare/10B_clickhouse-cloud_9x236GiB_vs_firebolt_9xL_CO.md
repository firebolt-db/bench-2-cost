### Cost Comparison: ClickHouse Cloud (AWS) vs Firebolt Cloud

#### Configuration

| Metric | ClickHouse Cloud (AWS) | Firebolt Cloud |
|--------|------------------------|----------------|
| Cluster Size | 9 | 9 |
| Machine/Engine | 236GiB | L_COMPUTE_OPTIMIZED |
| Data Size (GB) | 95.66 | 63.56 |

#### Performance (Best of 3 runs, 43/43 queries)

| Metric | ClickHouse Cloud (AWS) | Firebolt Cloud |
|--------|------------------------|----------------|
| Total Query Time | 98.982s | 39.690s |
| Queries Won | 3 | 40 |

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
| ClickHouse Cloud (AWS) (Enterprise) | $2.849160 |
| Firebolt Cloud (Enterprise) | $0.476280 |
| **Savings** | **Firebolt Cloud saves 83.3%** |

---

#### Compute Cost - Basic/Standard Tier (43 queries)

| System | Cost |
|--------|------|
| ClickHouse Cloud (AWS) (Basic) | $1.592186 |
| Firebolt Cloud (Standard) | $0.365148 |
| **Savings** | **Firebolt Cloud saves 77.1%** |

---

#### Compute Cost - Scale/Standard Tier (43 queries)

| System | Cost |
|--------|------|
| ClickHouse Cloud (AWS) (Scale) | $2.178735 |
| Firebolt Cloud (Standard) | $0.365148 |
| **Savings** | **Firebolt Cloud saves 83.2%** |

---

#### Summary

| Category | Winner | Savings |
|----------|--------|---------|
| Storage | Firebolt Cloud | 35.3% |
| Compute (Enterprise) | Firebolt Cloud | 83.3% |
| Compute (Basic/Standard) | Firebolt Cloud | 77.1% |
| Compute (Scale/Standard) | Firebolt Cloud | 83.2% |
| Query Performance | Firebolt Cloud | 59.9% faster |

---

#### Query Details

| ClickHouse Node | Firebolt Node | Cluster Size | Scan Cache | Query | ClickHouse Best | Firebolt Best | Firebolt Query Label |
|---|---|---|---|---|---|---|---|
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q1 | 0.002 | 0.010 | {"benchmark":"clickbench","volume":"10B","query":"q01","attempt":1} |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q2 | 0.355 | 0.123 | {"benchmark":"clickbench","volume":"10B","query":"q02","attempt":3} |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q3 | 0.581 | 0.212 | {"benchmark":"clickbench","volume":"10B","query":"q03","attempt":3} |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q4 | 0.552 | 0.191 | {"benchmark":"clickbench","volume":"10B","query":"q04","attempt":1} |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q5 | 0.974 | 0.287 | {"benchmark":"clickbench","volume":"10B","query":"q05","attempt":1} |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q6 | 1.242 | 0.962 | {"benchmark":"clickbench","volume":"10B","query":"q06","attempt":2} |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q7 | 0.401 | 0.129 | {"benchmark":"clickbench","volume":"10B","query":"q07","attempt":2} |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q8 | 0.432 | 0.095 | {"benchmark":"clickbench","volume":"10B","query":"q08","attempt":3} |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q9 | 1.480 | 0.386 | {"benchmark":"clickbench","volume":"10B","query":"q09","attempt":1} |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q10 | 1.741 | 1.141 | {"benchmark":"clickbench","volume":"10B","query":"q10","attempt":2} |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q11 | 0.858 | 0.391 | {"benchmark":"clickbench","volume":"10B","query":"q11","attempt":1} |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q12 | 1.086 | 0.444 | {"benchmark":"clickbench","volume":"10B","query":"q12","attempt":3} |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q13 | 1.223 | 0.656 | {"benchmark":"clickbench","volume":"10B","query":"q13","attempt":2} |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q14 | 1.842 | 0.827 | {"benchmark":"clickbench","volume":"10B","query":"q14","attempt":1} |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q15 | 1.581 | 0.719 | {"benchmark":"clickbench","volume":"10B","query":"q15","attempt":2} |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q16 | 1.011 | 0.353 | {"benchmark":"clickbench","volume":"10B","query":"q16","attempt":1} |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q17 | 2.931 | 1.268 | {"benchmark":"clickbench","volume":"10B","query":"q17","attempt":3} |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q18 | 2.621 | 1.260 | {"benchmark":"clickbench","volume":"10B","query":"q18","attempt":3} |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q19 | 4.490 | 1.750 | {"benchmark":"clickbench","volume":"10B","query":"q19","attempt":2} |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q20 | 0.138 | 0.036 | {"benchmark":"clickbench","volume":"10B","query":"q20","attempt":2} |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q21 | 1.569 | 1.786 | {"benchmark":"clickbench","volume":"10B","query":"q21","attempt":3} |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q22 | 2.019 | 1.681 | {"benchmark":"clickbench","volume":"10B","query":"q22","attempt":1} |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q23 | 3.756 | 1.578 | {"benchmark":"clickbench","volume":"10B","query":"q23","attempt":1} |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q24 | 7.854 | 1.753 | {"benchmark":"clickbench","volume":"10B","query":"q24","attempt":1} |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q25 | 1.028 | 0.521 | {"benchmark":"clickbench","volume":"10B","query":"q25","attempt":2} |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q26 | 0.862 | 0.724 | {"benchmark":"clickbench","volume":"10B","query":"q26","attempt":2} |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q27 | 0.979 | 0.508 | {"benchmark":"clickbench","volume":"10B","query":"q27","attempt":1} |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q28 | 2.056 | 2.483 | {"benchmark":"clickbench","volume":"10B","query":"q28","attempt":3} |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q29 | 27.065 | 7.080 | {"benchmark":"clickbench","volume":"10B","query":"q29","attempt":1} |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q30 | 0.491 | 0.111 | {"benchmark":"clickbench","volume":"10B","query":"q30","attempt":3} |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q31 | 1.699 | 0.866 | {"benchmark":"clickbench","volume":"10B","query":"q31","attempt":1} |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q32 | 4.380 | 0.947 | {"benchmark":"clickbench","volume":"10B","query":"q32","attempt":2} |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q33 | 6.490 | 1.522 | {"benchmark":"clickbench","volume":"10B","query":"q33","attempt":3} |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q34 | 5.534 | 2.922 | {"benchmark":"clickbench","volume":"10B","query":"q34","attempt":1} |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q35 | 5.546 | 2.905 | {"benchmark":"clickbench","volume":"10B","query":"q35","attempt":3} |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q36 | 0.777 | 0.320 | {"benchmark":"clickbench","volume":"10B","query":"q36","attempt":2} |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q37 | 0.166 | 0.120 | {"benchmark":"clickbench","volume":"10B","query":"q37","attempt":3} |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q38 | 0.200 | 0.101 | {"benchmark":"clickbench","volume":"10B","query":"q38","attempt":2} |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q39 | 0.134 | 0.092 | {"benchmark":"clickbench","volume":"10B","query":"q39","attempt":1} |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q40 | 0.339 | 0.245 | {"benchmark":"clickbench","volume":"10B","query":"q40","attempt":2} |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q41 | 0.226 | 0.060 | {"benchmark":"clickbench","volume":"10B","query":"q41","attempt":3} |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q42 | 0.199 | 0.062 | {"benchmark":"clickbench","volume":"10B","query":"q42","attempt":3} |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q43 | 0.072 | 0.063 | {"benchmark":"clickbench","volume":"10B","query":"q43","attempt":2} |
