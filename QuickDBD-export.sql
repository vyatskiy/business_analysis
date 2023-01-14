-- Exported from QuickDBD: https://www.quickdatabasediagrams.com/
-- NOTE! If you have used non-SQL datatypes in your design, you will have to change these here.

-- Modify this code to update the DB schema diagram.
-- To reset the sample schema, replace everything with
-- two dots ('..' - without quotes).
-- Регистр Льготно лекарственных препаратов

CREATE TABLE "Customer" (
    "CustomerID" int   NOT NULL,
    "Name" string   NOT NULL,
    "Address" string   NOT NULL,
    CONSTRAINT "pk_Customer" PRIMARY KEY (
        "CustomerID"
     )
);

CREATE TABLE "Order" (
    "OrderID" int   NOT NULL,
    "CustomerID" int   NOT NULL,
    "TotalAmount" money   NOT NULL,
    "OrderStatusID" int   NOT NULL,
    "ReliseDateTime" date   NOT NULL,
    CONSTRAINT "pk_Order" PRIMARY KEY (
        "OrderID"
     )
);

CREATE TABLE "Recipe" (
    "RecipeID" int   NOT NULL,
    "OrderID" int   NOT NULL,
    "BenefitID" int   NOT NULL,
    "Quantity" int   NOT NULL,
    CONSTRAINT "pk_Recipe" PRIMARY KEY (
        "RecipeID"
     )
);

CREATE TABLE "Benefit" (
    "BenefitID" int   NOT NULL,
    "Name" varchar(200)   NOT NULL,
    "Price" money   NOT NULL,
    "Producer" string   NOT NULL,
    CONSTRAINT "pk_Benefit" PRIMARY KEY (
        "BenefitID"
     ),
    CONSTRAINT "uc_Benefit_Name" UNIQUE (
        "Name"
    )
);

CREATE TABLE "OrderStatus" (
    "OrderStatusID" int   NOT NULL,
    "Name" string   NOT NULL,
    CONSTRAINT "pk_OrderStatus" PRIMARY KEY (
        "OrderStatusID"
     ),
    CONSTRAINT "uc_OrderStatus_Name" UNIQUE (
        "Name"
    )
);

ALTER TABLE "Order" ADD CONSTRAINT "fk_Order_CustomerID" FOREIGN KEY("CustomerID")
REFERENCES "Customer" ("CustomerID");

ALTER TABLE "Order" ADD CONSTRAINT "fk_Order_OrderStatusID" FOREIGN KEY("OrderStatusID")
REFERENCES "OrderStatus" ("OrderStatusID");

ALTER TABLE "Recipe" ADD CONSTRAINT "fk_Recipe_OrderID" FOREIGN KEY("OrderID")
REFERENCES "Order" ("OrderID");

ALTER TABLE "Recipe" ADD CONSTRAINT "fk_Recipe_BenefitID" FOREIGN KEY("BenefitID")
REFERENCES "Benefit" ("BenefitID");

CREATE INDEX "idx_Customer_Name"
ON "Customer" ("Name");




CREATE TABLE Customer (
    CustomerID INTEGER PRIMARY KEY,
    Name TEXT,
    Address TEXT
);

CREATE TABLE Benefit (
    BenefitID INTEGER PRIMARY KEY,
    Name TEXT,
    Price INTEGER,
    Producer TEXT
);

CREATE TABLE OrderStatus (
    OrderStatusID INTEGER PRIMARY KEY,
    StatusCode INTEGER
);

CREATE TABLE Orders (
    OrderID INTEGER PRIMARY KEY,
    CustomerID INTEGER,
    TotalAmount INTEGER,
    OrderStatusID INTEGER,
    ReliseDateTime TEXT,

    FOREIGN KEY(CustomerID) REFERENCES Customer(CustomerID),
    FOREIGN KEY(OrderStatusID) REFERENCES OrderStatus(OrderStatusID)
);

CREATE TABLE Recipe (
    RecipeID INTEGER PRIMARY KEY,
    OrderID INTEGER,
    BenefitID INTEGER,
    Quantity INTEGER,

    FOREIGN KEY(OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY(BenefitID) REFERENCES Benefit(BenefitID)
);