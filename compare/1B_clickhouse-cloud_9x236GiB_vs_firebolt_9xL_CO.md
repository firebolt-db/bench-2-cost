### Cost Comparison: ClickHouse Cloud (AWS) vs Firebolt Cloud

#### Configuration

| Metric | ClickHouse Cloud (AWS) | Firebolt Cloud |
|--------|------------------------|----------------|
| Cluster Size | 9 | 9 |
| Machine/Engine | 236GiB | L_COMPUTE_OPTIMIZED |
| Data Size (GB) | 44.54 | 25.37 |

#### Performance (Best of 3 runs, 43/43 queries)

| Metric | ClickHouse Cloud (AWS) | Firebolt Cloud |
|--------|------------------------|----------------|
| Total Query Time | 23.172s | 9.539s |
| Queries Won | 10 | 32 |

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
| ClickHouse Cloud (AWS) (Enterprise) | $0.666997 |
| Firebolt Cloud (Enterprise) | $0.114468 |
| **Savings** | **Firebolt Cloud saves 82.8%** |

---

#### Compute Cost - Basic/Standard Tier (43 queries)

| System | Cost |
|--------|------|
| ClickHouse Cloud (AWS) (Basic) | $0.372736 |
| Firebolt Cloud (Standard) | $0.087759 |
| **Savings** | **Firebolt Cloud saves 76.5%** |

---

#### Compute Cost - Scale/Standard Tier (43 queries)

| System | Cost |
|--------|------|
| ClickHouse Cloud (AWS) (Scale) | $0.510049 |
| Firebolt Cloud (Standard) | $0.087759 |
| **Savings** | **Firebolt Cloud saves 82.8%** |

---

#### Summary

| Category | Winner | Savings |
|----------|--------|---------|
| Storage | Firebolt Cloud | 44.6% |
| Compute (Enterprise) | Firebolt Cloud | 82.8% |
| Compute (Basic/Standard) | Firebolt Cloud | 76.5% |
| Compute (Scale/Standard) | Firebolt Cloud | 82.8% |
| Query Performance | Firebolt Cloud | 58.8% faster |

---

#### Query Details

| ClickHouse Node | Firebolt Node | Cluster Size | Scan Cache | Query | ClickHouse Best | Firebolt Best | Firebolt Query Label |
|---|---|---|---|---|---|---|---|
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q1 | 0.002 | 0.006 | {"benchmark":"clickbench","volume":"1B","query":"q01","attempt":3} |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q2 | 0.027 | 0.059 | {"benchmark":"clickbench","volume":"1B","query":"q02","attempt":3} |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q3 | 0.032 | 0.060 | {"benchmark":"clickbench","volume":"1B","query":"q03","attempt":1} |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q4 | 0.033 | 0.061 | {"benchmark":"clickbench","volume":"1B","query":"q04","attempt":3} |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q5 | 0.365 | 0.119 | {"benchmark":"clickbench","volume":"1B","query":"q05","attempt":3} |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q6 | 0.270 | 0.209 | {"benchmark":"clickbench","volume":"1B","query":"q06","attempt":2} |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q7 | 0.023 | 0.038 | {"benchmark":"clickbench","volume":"1B","query":"q07","attempt":3} |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q8 | 0.032 | 0.039 | {"benchmark":"clickbench","volume":"1B","query":"q08","attempt":3} |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q9 | 0.554 | 0.140 | {"benchmark":"clickbench","volume":"1B","query":"q09","attempt":2} |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q10 | 0.530 | 0.340 | {"benchmark":"clickbench","volume":"1B","query":"q10","attempt":1} |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q11 | 0.127 | 0.096 | {"benchmark":"clickbench","volume":"1B","query":"q11","attempt":2} |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q12 | 0.134 | 0.105 | {"benchmark":"clickbench","volume":"1B","query":"q12","attempt":1} |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q13 | 0.381 | 0.175 | {"benchmark":"clickbench","volume":"1B","query":"q13","attempt":3} |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q14 | 0.536 | 0.342 | {"benchmark":"clickbench","volume":"1B","query":"q14","attempt":3} |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q15 | 0.490 | 0.190 | {"benchmark":"clickbench","volume":"1B","query":"q15","attempt":2} |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q16 | 0.440 | 0.126 | {"benchmark":"clickbench","volume":"1B","query":"q16","attempt":2} |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q17 | 1.085 | 0.324 | {"benchmark":"clickbench","volume":"1B","query":"q17","attempt":3} |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q18 | 0.629 | 0.322 | {"benchmark":"clickbench","volume":"1B","query":"q18","attempt":2} |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q19 | 2.019 | 0.515 | {"benchmark":"clickbench","volume":"1B","query":"q19","attempt":2} |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q20 | 0.030 | 0.032 | {"benchmark":"clickbench","volume":"1B","query":"q20","attempt":2} |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q21 | 0.455 | 0.249 | {"benchmark":"clickbench","volume":"1B","query":"q21","attempt":3} |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q22 | 0.457 | 0.259 | {"benchmark":"clickbench","volume":"1B","query":"q22","attempt":1} |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q23 | 1.078 | 0.298 | {"benchmark":"clickbench","volume":"1B","query":"q23","attempt":2} |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q24 | 0.468 | 0.285 | {"benchmark":"clickbench","volume":"1B","query":"q24","attempt":1} |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q25 | 0.100 | 0.115 | {"benchmark":"clickbench","volume":"1B","query":"q25","attempt":3} |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q26 | 0.088 | 0.149 | {"benchmark":"clickbench","volume":"1B","query":"q26","attempt":3} |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q27 | 0.102 | 0.102 | {"benchmark":"clickbench","volume":"1B","query":"q27","attempt":3} |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q28 | 0.333 | 0.367 | {"benchmark":"clickbench","volume":"1B","query":"q28","attempt":3} |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q29 | 3.098 | 1.038 | {"benchmark":"clickbench","volume":"1B","query":"q29","attempt":2} |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q30 | 0.064 | 0.050 | {"benchmark":"clickbench","volume":"1B","query":"q30","attempt":3} |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q31 | 0.390 | 0.215 | {"benchmark":"clickbench","volume":"1B","query":"q31","attempt":3} |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q32 | 0.542 | 0.258 | {"benchmark":"clickbench","volume":"1B","query":"q32","attempt":2} |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q33 | 2.521 | 0.722 | {"benchmark":"clickbench","volume":"1B","query":"q33","attempt":2} |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q34 | 2.487 | 0.799 | {"benchmark":"clickbench","volume":"1B","query":"q34","attempt":2} |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q35 | 2.240 | 0.794 | {"benchmark":"clickbench","volume":"1B","query":"q35","attempt":2} |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q36 | 0.151 | 0.107 | {"benchmark":"clickbench","volume":"1B","query":"q36","attempt":1} |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q37 | 0.103 | 0.063 | {"benchmark":"clickbench","volume":"1B","query":"q37","attempt":2} |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q38 | 0.064 | 0.061 | {"benchmark":"clickbench","volume":"1B","query":"q38","attempt":1} |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q39 | 0.125 | 0.061 | {"benchmark":"clickbench","volume":"1B","query":"q39","attempt":3} |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q40 | 0.335 | 0.104 | {"benchmark":"clickbench","volume":"1B","query":"q40","attempt":2} |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q41 | 0.083 | 0.049 | {"benchmark":"clickbench","volume":"1B","query":"q41","attempt":1} |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q42 | 0.078 | 0.048 | {"benchmark":"clickbench","volume":"1B","query":"q42","attempt":3} |
| 236GiB | L_COMPUTE_OPTIMIZED | 9 | False | Q43 | 0.071 | 0.048 | {"benchmark":"clickbench","volume":"1B","query":"q43","attempt":2} |
