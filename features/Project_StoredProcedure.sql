# Vendor가 Cooking company에 발주를 넣을 때, OrderingQuantity가  MakingQuantity보다 많을 시 발주 불가 안내문 나오게 하는 Stored Procedure

DELIMITER //

CREATE PROCEDURE CheckOrderingPossibility(
    IN p_VendorID INT,
    IN p_OrderingQuantity INT,
    IN p_CookingCompanyID INT,
    OUT p_ResultMessage VARCHAR(255)
)
BEGIN
    DECLARE cooking_company_making_quantity INT;
    
    -- Cooking Company의 Making Quantity 조회
    SELECT MakingQuantity INTO cooking_company_making_quantity
    FROM COOKING_COMPANY
    WHERE CookingCompanyID = p_CookingCompanyID;
    
    -- 발주 불가 조건 확인
    IF p_OrderingQuantity > cooking_company_making_quantity THEN
        SET p_ResultMessage = 'Out of Quantity - cannot order';
    ELSE
        SET p_ResultMessage = 'Order is possible';
    END IF;
END //

DELIMITER ;


# 새로운 VENDOR 특성 등록
DELIMITER //

CREATE PROCEDURE AddNewVendor(
    IN p_VendorID INT,
    IN p_VendorName VARCHAR(25)

)
BEGIN
    -- 새로운 Vendor 등록
    INSERT INTO VENDOR (VendorID, VendorName)
    VALUES (p_VendorID, p_VendorName);
    
    SELECT 'Vendor added successfully' AS Message;
END //

DELIMITER ;


# 제조회사의 총 제작비용을 계산하는 프로시저
DELIMITER //

CREATE PROCEDURE CalculateTotalCost(
    IN p_CookingCompanyID INT
)
BEGIN
    DECLARE making_quantity INT;
    DECLARE unit_cost DECIMAL(10, 2);
    DECLARE total_cost DECIMAL(10, 2);

    -- Making Quantity 및 Unit Cost 조회
    SELECT MakingQuantity, UnitCost INTO making_quantity, unit_cost
    FROM COOKING_COMPANY
    WHERE CookingCompanyID = p_CookingCompanyID;

    -- Total Cost 계산
    SET total_cost = making_quantity * unit_cost;

    -- 결과 출력
    SELECT total_cost AS TotalCost;
END //

DELIMITER ;