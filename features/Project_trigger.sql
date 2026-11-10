
# FRIDGE에 재료 추가 시 ingredient에 표기되는 수량 업데이트
DELIMITER //

CREATE TRIGGER update_fridge_quantity
AFTER INSERT ON INGREDIENT
FOR EACH ROW
BEGIN
    UPDATE FRIDGE
    SET FridgeQuantity = FridgeQuantity + NEW.IngredientStorageNumber
    WHERE FridgeID = NEW.FridgeID;
END //

DELIMITER ;

# 새로운 Ingredient가 추가될 시 Ingredient_info에 자동적으로 재료 등록
DELIMITER //

CREATE TRIGGER update_ingredient_info
AFTER INSERT ON INGREDIENT
FOR EACH ROW
BEGIN
    INSERT INTO INGREDIENT_INFO (IngredientName, IngredientID)
    VALUES (NEW.IngredientName, NEW.IngredientID);
END //

DELIMITER ;

