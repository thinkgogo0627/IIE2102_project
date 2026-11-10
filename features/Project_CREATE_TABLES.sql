-- Storage Company 테이블
CREATE TABLE STORAGE_COMPANY (
    StorageCompanyID INT NOT NULL,
    StorageCompanyName VARCHAR(25) NOT NULL,
    PRIMARY KEY (StorageCompanyID)
);

-- Fridge 테이블
CREATE TABLE FRIDGE (
    FridgeID INT NOT NULL,
    FridgeLocation VARCHAR(50) NOT NULL, 
    StorageCompanyID INT NOT NULL,
    PRIMARY KEY (FridgeID),
    FOREIGN KEY (StorageCompanyID) REFERENCES STORAGE_COMPANY(StorageCompanyID)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);


-- Ingredient 테이블
CREATE TABLE INGREDIENT (
    IngredientID VARCHAR(5) NOT NULL,
    IngredientName VARCHAR(25) NOT NULL,
    IngredientStorageNumber INT NOT NULL,
    FridgeID INT NOT NULL,
    PRIMARY KEY (IngredientID),
    FOREIGN KEY (FridgeID) REFERENCES FRIDGE(FridgeID)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

-- Receipie 테이블
CREATE TABLE RECEIPE (
    ReceipieID INT NOT NULL,
    ReceipieName VARCHAR(25) NOT NULL,
    IngredientQuantity INT NOT NULL,
    IngredientID VARCHAR(5) NOT NULL,
    PRIMARY KEY (ReceipieID, ReceipieName, IngredientQuantity, IngredientID),
    FOREIGN KEY (IngredientID) REFERENCES INGREDIENT(IngredientID)
        ON UPDATE CASCADE
        ON DELETE NO ACTION
);

-- Ingredientinfo 테이블
CREATE TABLE INGREDIENT_INFO (
		IngredientName VarChar(50) NOT NULL,
        IngredientOrigin Varchar(50) NOT NULL,
        IngredientCost   int	NULL,
        IngredientID	Varchar(5) 	NOT NULL,
        PRIMARY KEY(IngredientName, IngredientID),
        FOREIGN KEY(IngredientID) REFERENCES INGREDIENT(IngredientID)
			ON UPDATE CASCADE
            ON DELETE CASCADE);


-- Cooking Company 테이블
CREATE TABLE COOKING_COMPANY (
    CookingCompanyID INT NOT NULL,
    CookingCompanyName VARCHAR(25) NOT NULL,
    MakingQuantity INT NOT NULL,
    ReceipieID INT NOT NULL, 
    ReceipieName VARCHAR(25) NOT NULL, 
    PRIMARY KEY (CookingCompanyID, CookingCompanyName, ReceipieId),
    FOREIGN KEY (ReceipieID, ReceipieName) REFERENCES RECEIPE(ReceipieID, ReceipieName)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

-- Vendor 테이블
CREATE TABLE VENDOR (
    VendorID INT NOT NULL,
    VendorName VARCHAR(25) NOT NULL,
    OrderingQuantity INT NULL,
    OrderingDate DATE NULL, 
    CookingCompanyID INT NULL, 
    PRIMARY KEY (VendorID),
    FOREIGN KEY (CookingCompanyID) REFERENCES COOKING_COMPANY(CookingCompanyID)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

