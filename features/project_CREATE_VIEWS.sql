# View 1 - 각 Fridge별 보관 재료 확인 VIEW
CREATE VIEW FridgehasIngredient AS
	SELECT F.FridgeID, S.StorageCompanyName,
		   I.IngredientName, I.IngredientStorageNumber
	FROM storage_company as S JOIN FRIDGE AS F ON S.StorageCompanyID = F.StorageCompanyID
		 JOIN INGREDIENT AS I ON I.FridgeID = F.FridgeID;

# 사용예시 - FridgehasIngredient
SELECT *
FROM fridgehasingredient;




# View 2 - 각 제조회사별 밀키트 제작갯수와 이를 발주하는 회사를 확인하는 VIEW
CREATE VIEW MealKitGoodsQuantity AS
	SELECT CC.CookingCompanyName, CC.MakingQuantity,
		   R.ReceipieName, V.VendorName
	FROM cooking_company as CC JOIN receipe AS R ON CC.ReceipieID = R.ReceipieID
		 JOIN Vendor as V ON V.CookingCompanyID = CC.CookingCompanyID
	GROUP BY CookingCompanyName, MakingQuantity, ReceipieName, VendorName;

# 사용예시 - MealKitGoodsQuantity    
SELECT *
FROM MealKitGoodsQuantity;

# VieW 3 - Cooking Company가 사용하는 재료 및 해당 재료의 총 비용을 표시하는 VIEW
CREATE VIEW CookingCompanyIngredientCost AS
    SELECT
        CC.CookingCompanyName,
        R.ReceipieName,
        II.IngredientName,
        II.IngredientCost,
        R.IngredientQuantity,
        (II.IngredientCost * R.IngredientQuantity) AS TotalCost
    FROM
        cooking_company AS CC
    JOIN
        receipe AS R ON CC.ReceipieID = R.ReceipieID
    JOIN
        ingredient_info AS II ON R.IngredientID = II.IngredientID;

# 사용예시
SELECT *
FROM CookingCompanyIngredientCost;
