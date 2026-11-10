# 냉동고에 있는 재료의 총 수량 계산하는 Function
DELIMITER //

CREATE FUNCTION CalculateTotalIngredientQuantity(
    p_FridgeID INT
)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE total_quantity INT;
    
    -- 냉동고에 있는 재료의 총 수량 계산
    SELECT SUM(IngredientStorageNumber) INTO total_quantity
    FROM INGREDIENT
    WHERE FridgeID = p_FridgeID;
    
    RETURN total_quantity;
END //

DELIMITER ;

# Example 1 - FridgeID가 1인 냉동고에 있는 재료의 총 수량을 계산
SELECT CalculateTotalIngredientQuantity(1) AS TotalIngredientQuantity;


DELIMITER //


# 재료 수량을 바탕으로 요리를 몇 개 만들 수 있는지 알려주는 함수 
CREATE FUNCTION CalculateMaxRecipeCount(
    p_ReceipieID INT
)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE max_recipe_count INT;
    
    -- 해당 레시피에 필요한 총 재료 수량 계산
    SELECT SUM(INGREDIENT.IngredientStorageNumber) INTO max_recipe_count
    FROM INGREDIENT
    JOIN RECEIPE ON INGREDIENT.IngredientID = RECEIPE.IngredientID
    WHERE RECEIPE.ReceipieID = p_ReceipieID;
    
    -- 레시피에 필요한 재료 수량을 가진 최대 요리 수량 계산
    IF max_recipe_count IS NOT NULL THEN
        SET max_recipe_count = FLOOR(max_recipe_count / RECEIPE.IngredientQuantity);
    ELSE
        SET max_recipe_count = 0;
    END IF;

    RETURN max_recipe_count;
END //

DELIMITER ;

# 밀키트 생산 총 비용 확인 함수
DELIMITER //

CREATE FUNCTION CalculateProductionCost(
    p_MakingQuantity INT,
    p_UnitCost DECIMAL(10, 2)
)
RETURNS DECIMAL(10, 2)
BEGIN
    DECLARE total_cost DECIMAL(10, 2);
    
    -- 생산 비용 계산
    SET total_cost = p_MakingQuantity * p_UnitCost;
    
    RETURN total_cost;
END //

DELIMITER ;



