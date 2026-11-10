# 밀키트 업체 공급망 관리를 위한 DB 구축

> 2023년 2학기 산업정보관리론 Term Project · **Team 09**
> 정호진 (2022147009) · 김성민 (2020147005)

밀키트 공급망에 속한 **원자재 보관업체(Storage Company) → 제조업체(Cooking Company) → 판매점(Vendor)** 의 데이터를 하나의 MySQL 데이터베이스로 통합하고, VIEW · Trigger · Stored Procedure · User Defined Function과 Python(Tkinter) 응용프로그램으로 각 구성원의 의사결정을 지원하는 프로젝트입니다.

---

## 목차
1. [프로젝트 배경](#1-프로젝트-배경)
2. [프로젝트 구조](#2-프로젝트-구조)
3. [ER 모델](#3-er-모델)
4. [테이블 설계](#4-테이블-설계)
5. [VIEW](#5-view)
6. [SQL/PSM](#6-sqlpsm)
7. [응용프로그램](#7-응용프로그램)
8. [실행 방법](#8-실행-방법)
9. [결론 및 향후 개선점](#9-결론-및-향후-개선점)

---

## 1. 프로젝트 배경

- 밀키트 수요는 1~2인 가구, 맞벌이 가구를 중심으로 꾸준히 성장해 왔습니다.
- 코로나19 이후 내식·비대면을 선호하는 소비자가 늘면서 판매점의 완제품 주문이 증가했습니다.
- 제조사는 완제품을 공급하기 위해 원자재를 조달해야 하고, 원자재는 냉동창고에 보관됩니다.
- 결국 전체 과정이 하나의 **공급망(SCM)** 형태를 띠므로, 공급망 구성원 전체의 데이터를 관리하는 DB를 구축해 각 구성원의 운영 최적화와 의사결정을 돕고 밀키트 산업의 동향을 파악하는 데 활용하고자 했습니다.

```
 Storage Company ──(원자재 공급)──▶ Cooking Company ──(완성 제품 공급)──▶ Vendor ──(완제품 판매)──▶ Customer
   (냉동창고 보유)    ◀──(원자재 구매)──    (밀키트 제조)    ◀──(완성 제품 주문)──   (판매점)
                         └──────────────── Integrated DB System ────────────────┘
```

> Customer는 데이터 규모와 복잡도 문제로 이번 DB 범위에서는 제외했습니다. ([9. 향후 개선점](#9-결론-및-향후-개선점) 참고)

---

## 2. 프로젝트 구조

```
Project_TEAM09
├── data/                               # MySQL Data Import용 CSV 데이터
│   ├── Storage_company.csv             # 냉동창고 보유 업체 (9건)
│   ├── Fridge.csv                      # 냉동고 (16건)
│   ├── Ingredient.csv                  # 재료 및 보관 수량 (25건)
│   ├── ingredientinfo.csv              # 재료 원산지·단가 (25건)
│   ├── Receipie.csv                    # 레시피별 필요 재료·수량 (41건)
│   ├── Cooking_company.csv             # 밀키트 제조회사 (22건)
│   └── vendor.csv                      # 판매점 발주 정보 (16건)
├── docs/
│   ├── Term_Project_Team9.pdf          # 발표 자료 (요구사항 분석, ER 모델, 설계, 결론)
│   └── Team09_SQL 및 응용프로그램 설명.pdf  # SQL / 응용프로그램 실행 설명서
├── features/
│   ├── TermProject_ER MODEL.mwb        # MySQL Workbench ER 모델
│   ├── Project_CREATE_TABLES.sql       # 테이블 생성
│   ├── project_CREATE_VIEWS.sql        # VIEW 3종
│   ├── Project_Userdefinefunction.sql  # User Defined Function 3종
│   ├── Project_trigger.sql             # Trigger 2종
│   ├── Project_StoredProcedure.sql     # Stored Procedure 3종
│   └── project_applied_program.py      # Python(Tkinter + PyMySQL) 응용프로그램
└── README.md
```

---

## 3. ER 모델

ER 모델 원본은 [`features/TermProject_ER MODEL.mwb`](features/TermProject_ER%20MODEL.mwb) (MySQL Workbench)에 있습니다.

```
STORAGE_COMPANY 1 ──< FRIDGE 1 ──< INGREDIENT 1 ── 1 INGREDIENT_INFO
                                       │
                                       └──< RECEIPE (RECEIPE_has_INGREDIENT, N:M)
                                                 │
                                                 └──< COOKING_COMPANY 1 ──< VENDOR
```

### Cardinality
| 관계 | 설명 |
|---|---|
| STORAGE_COMPANY – FRIDGE | 하나의 보관업체는 최소 1개 이상의 냉동고를 가지며, 냉동고는 반드시 하나의 보관업체 소유 |
| FRIDGE – INGREDIENT | 냉동고에는 여러 재료가 있을 수 있고 비어 있어도 됨. 재료는 반드시 하나의 냉동고에 보관 |
| INGREDIENT – INGREDIENT_INFO | INGREDIENT_INFO는 재료의 부가 설명으로, INGREDIENT에 **ID-dependent** |
| INGREDIENT – RECEIPE | N:M 관계 (`RECEIPE_has_INGREDIENT`가 intersection table). 레시피는 반드시 재료를 가지며, 레시피에 쓰이지 않는 재료도 존재 가능 |
| RECEIPE – COOKING_COMPANY | 하나의 레시피는 여러 제조회사에서 사용될 수 있으며, 한 제조회사는 반드시 하나의 레시피만 사용 |
| COOKING_COMPANY – VENDOR | 제조회사는 여러 판매점에 공급할 수 있고 공급하지 않아도 됨. 판매점은 반드시 하나의 제조회사로부터만 공급받음 |

---

## 4. 테이블 설계

모든 FK 관계는 `ON UPDATE CASCADE`를 사용하며, `RECEIPE → INGREDIENT`만 `ON DELETE NO ACTION`, 나머지는 `ON DELETE CASCADE`입니다.

| 테이블 | 설명 | 주요 컬럼 | PK | FK |
|---|---|---|---|---|
| `STORAGE_COMPANY` | 재료를 보관할 냉동창고를 소유한 업체 (실제 대형 냉동창고 업체 기반) | StorageCompanyID, StorageCompanyName | StorageCompanyID | – |
| `FRIDGE` | 재료를 실제로 보관하는 냉동고 | FridgeID, FridgeLocation | FridgeID | StorageCompanyID |
| `INGREDIENT` | 냉동고에 보관되는 재료와 보관 수량 | IngredientID, IngredientName, IngredientStorageNumber | IngredientID | FridgeID |
| `INGREDIENT_INFO` | 재료의 원산지, 단위당 가격 | IngredientName, IngredientOrigin, IngredientCost | (IngredientName, IngredientID) | IngredientID |
| `RECEIPE` | 밀키트 레시피별 필요한 재료와 수량 | ReceipieID, ReceipieName, IngredientQuantity | (ReceipieID, ReceipieName, IngredientQuantity, IngredientID) | IngredientID |
| `COOKING_COMPANY` | 재료로 밀키트 완성본을 제조하는 회사 | CookingCompanyID, CookingCompanyName, MakingQuantity, UnitCost | (CookingCompanyID, CookingCompanyName, ReceipieID) | (ReceipieID, ReceipieName) |
| `VENDOR` | 제조회사로부터 밀키트를 발주받아 판매하는 판매점 | VendorID, VendorName, OrderingQuantity, OrderingDate | VendorID | CookingCompanyID |

### 데이터
- 모든 데이터는 CSV로 작성한 뒤 **MySQL Workbench의 Table Data Import Wizard**로 삽입했습니다.
- 재료의 실제 보관 수량은 알 수 없어, Excel 난수를 이용해 밀키트 제조에 충분한 수량으로 설정했습니다.
- 레시피: 잡채, 불고기, 제육볶음, 된장찌개, 소고기무국, 닭볶음탕, 소시지야채볶음 등
- 제조회사 예시: Fresh Easy, Simply Cook, Cookit, It'son, GSRetail, Happycook, Ourhome 등

---

## 5. VIEW

`features/project_CREATE_VIEWS.sql`

| VIEW | 설명 |
|---|---|
| `FridgehasIngredient` | 냉동고별 보관업체명, 보관 중인 재료와 수량 확인 |
| `MealKitGoodsQuantity` | 제조회사별 밀키트 제작 수량, 레시피, 이를 발주하는 판매점 확인 |
| `CookingCompanyIngredientCost` | 제조회사별 사용 재료, 재료 단가, 필요 수량과 재료별 총 비용(`IngredientCost × IngredientQuantity`) |

```sql
SELECT * FROM FridgehasIngredient;
SELECT * FROM MealKitGoodsQuantity;
SELECT * FROM CookingCompanyIngredientCost;
```

---

## 6. SQL/PSM

### 6-1. Trigger — `features/Project_trigger.sql`
| Trigger | 시점 | 설명 |
|---|---|---|
| `update_fridge_quantity` | `AFTER INSERT ON INGREDIENT` | 냉동고에 재료가 추가되면 해당 냉동고의 보관 수량을 갱신 (재료 수량 변동은 밀키트 생산 가능량에 영향) |
| `update_ingredient_info` | `AFTER INSERT ON INGREDIENT` | 새 재료가 등록되면 `INGREDIENT_INFO`에 재료 정보를 자동 등록 (새 밀키트 생산 가능성에 바로 대응) |

두 동작 모두 INGREDIENT 등록 이후에 일어나야 하므로 `AFTER` 트리거로 설정했습니다.

### 6-2. Stored Procedure — `features/Project_StoredProcedure.sql`
| Procedure | 파라미터 | 설명 |
|---|---|---|
| `CheckOrderingPossibility` | `IN p_VendorID, IN p_OrderingQuantity, IN p_CookingCompanyID, OUT p_ResultMessage` | 판매점 발주량이 제조회사 생산량(MakingQuantity)을 초과하면 `'Out of Quantity - cannot order'`, 아니면 `'Order is possible'` 반환 |
| `AddNewVendor` | `IN p_VendorID, IN p_VendorName` | 새로운 판매점 등록 |
| `CalculateTotalCost` | `IN p_CookingCompanyID` | 제조회사의 총 제작비용(`MakingQuantity × UnitCost`) 계산 |

```sql
CALL CheckOrderingPossibility(1, 3000, 1, @msg); SELECT @msg;
CALL AddNewVendor(24, 'SanJungGwan');
CALL CalculateTotalCost(1);
```

### 6-3. User Defined Function — `features/Project_Userdefinefunction.sql`
| Function | 반환 | 설명 |
|---|---|---|
| `CalculateTotalIngredientQuantity(p_FridgeID)` | INT | 해당 냉동고에 보관 중인 재료의 총 수량 |
| `CalculateMaxRecipeCount(p_ReceipieID)` | INT | 재료 보관 수량을 바탕으로 만들 수 있는 요리 개수 |
| `CalculateProductionCost(p_MakingQuantity, p_UnitCost)` | DECIMAL(10,2) | 밀키트 생산에 필요한 총 비용 |

```sql
SELECT CalculateTotalIngredientQuantity(1) AS TotalIngredientQuantity;
SELECT CalculateProductionCost(2011, 9);
```

---

## 7. 응용프로그램

`features/project_applied_program.py` — **Python + Tkinter(GUI) + PyMySQL**

실행하면 "어떤 업체로 로그인하시겠습니까?" 창이 뜨고, 로그인 주체를 선택하면 각 주체에 맞는 기능이 열립니다.

| 로그인 주체 | 기능 | 연동 DB 객체 |
|---|---|---|
| **Vendor** | 새 VendorID, VendorName 등록 (기존 VendorID와 겹치지 않아야 함 – PK 중복 방지) | Stored Procedure `AddNewVendor` |
| **Cooking Company** | 제조회사 ID 입력 시 지금까지 밀키트 제작에 사용된 총 비용 계산 | Stored Procedure `CalculateTotalCost` |
| **Storage Company** | ID 입력 시 보관 중인 총 재료 개수 계산 | Function `CalculateTotalIngredientQuantity` |

결과는 콘솔(stdout)에 출력됩니다.

---

## 8. 실행 방법

### 요구 사항
- MySQL 8.x (+ MySQL Workbench 권장)
- Python 3.x, `pymysql` (Tkinter는 Python 기본 포함)

```bash
pip install pymysql
```

### A. DB 구축
1. 스키마 생성 (응용프로그램 기본값은 `project`)
   ```sql
   CREATE DATABASE project;
   USE project;
   ```
2. `features/Project_CREATE_TABLES.sql` 실행 → 테이블 생성
3. `data/`의 CSV 파일을 MySQL Workbench **Table Data Import Wizard**로 각 테이블에 삽입
   (FK 순서: `STORAGE_COMPANY` → `FRIDGE` → `INGREDIENT` → `INGREDIENT_INFO` → `RECEIPE` → `COOKING_COMPANY` → `VENDOR`)
4. 다음 순서로 SQL 파일 실행
   1. `features/project_CREATE_VIEWS.sql`
   2. `features/Project_Userdefinefunction.sql`
   3. `features/Project_trigger.sql`
   4. `features/Project_StoredProcedure.sql`

### B. 응용프로그램 실행
1. `features/project_applied_program.py`의 `Database` 클래스에서 `host`, `port`, `user`, `password`, `db`를 본인 환경에 맞게 수정
   ```python
   self.db = pymysql.connect(host='localhost', port=3306,
                             user='root', password='<your password>',
                             db='project', charset='utf8')
   ```
2. 실행
   ```bash
   python features/project_applied_program.py
   ```

### 참고: 코드와 데이터 간 불일치
현재 소스 기준으로 그대로 실행하면 일부 객체가 동작하지 않을 수 있습니다.
- `COOKING_COMPANY` 테이블 정의에 `UnitCost` 컬럼이 없지만, `Cooking_company.csv`와 `CalculateTotalCost` 프로시저는 이 컬럼을 사용합니다. → 테이블에 `UnitCost INT` 컬럼 추가 필요
- `update_fridge_quantity` 트리거가 참조하는 `FRIDGE.FridgeQuantity` 컬럼이 테이블 정의에 없습니다.
- CSV 헤더명이 테이블 컬럼명과 일부 다르므로(`CoookingCompanyID`, `RecipeID`, `INGREDIENT_IngredientID` 등) Import 시 컬럼 매핑을 확인해야 합니다.
- 응용프로그램의 Storage Company 기능은 입력값을 `CalculateTotalIngredientQuantity`에 그대로 넘기므로, 실제로는 **FridgeID 기준** 재료 수량이 계산됩니다.

---

## 9. 결론 및 향후 개선점

### 결과
- 밀키트 공급망 DB를 구축하고, 각 구성원의 의사결정을 돕는 VIEW와 PSM을 구현했습니다.
- 제품 총 생산비용, 제조회사의 총 생산비용, 판매점의 발주 가능 여부 확인 등의 기능을 제공합니다.
- 구축된 DB를 통해 공급망을 최적화하고, 데이터 분석으로 밀키트 산업에 대한 인사이트를 얻을 수 있습니다.

### 향후 개선점
- **Customer 포함**: 판매점에서 제품을 구매하는 고객까지 포함하려 했으나, 유의미한 고객 데이터는 규모가 지나치게 크고 축소하면 의미가 사라질 것으로 판단해 제외했습니다. 유의미한 정보만 추출·압축하거나 대용량 데이터를 다루는 DBMS를 사용하는 방안이 있습니다.
- **공급망 확장**: 본 프로젝트는 공급망 구성원을 3개로 단순화했지만 실제 산업은 훨씬 복잡합니다. 산업 환경에 대한 이해를 바탕으로 전체 참가자와 이들의 Cardinality를 명확히 하고, 예를 들어 냉동창고에서 제조회사로 원자재를 운송하는 **운송업체** 등을 추가할 수 있습니다.

---

📄 자세한 내용은 [`docs/Term_Project_Team9.pdf`](docs/Term_Project_Team9.pdf)와 [`docs/Team09_SQL 및 응용프로그램 설명.pdf`](docs/Team09_SQL%20및%20응용프로그램%20설명.pdf)를 참고하세요.
