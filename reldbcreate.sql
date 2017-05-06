CREATE TABLE "USER"(
    ID              SERIAL PRIMARY KEY,
    UNIQUE_NAME     VARCHAR(255) NOT NULL UNIQUE,
    OWNER           BOOLEAN NOT NULL,
    AGE             INTEGER NOT NULL,
    STATE           VARCHAR(255) NOT NULL DEFAULT 'CA'
);
CREATE TABLE CATEGORY(
    ID              SERIAL PRIMARY KEY,
    USER_ID         INTEGER REFERENCES "USER"(ID) NOT NULL,
    UNIQUE_NAME     VARCHAR(255) NOT NULL UNIQUE,
    "DESC"          VARCHAR(1023)
);
CREATE TABLE PRODUCT(
    ID              SERIAL PRIMARY KEY,
    UNIQUE_NAME     VARCHAR(255) NOT NULL UNIQUE,
    SKU             VARCHAR(255) NOT NULL,
    CATEGORY_ID     INTEGER REFERENCES CATEGORY(ID) NOT NULL,
    PRICE           INTEGER NOT NULL DEFAULT 0
);
CREATE TABLE PURCHASE(
    ID              SERIAL PRIMARY KEY,
    USER_ID         INTEGER REFERENCES "USER"(ID) NOT NULL,
    PRODUCT_ID      INTEGER REFERENCES PRODUCT(ID) NOT NULL,
    QUANTITY        INTEGER NOT NULL DEFAULT 1,
    TIME            TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE CART(
    ID              SERIAL PRIMARY KEY,
    USER_ID         INTEGER REFERENCES "USER"(ID) NOT NULL,
    PRODUCT_ID      INTEGER REFERENCES PRODUCT(ID) NOT NULL,
    QUANTITY        INTEGER NOT NULL DEFAULT 1
);
