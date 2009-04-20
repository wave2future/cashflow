BEGIN TRANSACTION;
CREATE TABLE Transactions (key INTEGER PRIMARY KEY,asset INTEGER,dst_asset INTEGER,date DATE,type INTEGER,category INTEGER,value REAL,description TEXT,memo TEXT);
INSERT INTO "Transactions" VALUES(1,1,-1,200901010900,0, 1,  -100,'drink' ,'');
INSERT INTO "Transactions" VALUES(2,1,-1,200901022015,0, 2,  -800,'taxi'  ,'');
INSERT INTO "Transactions" VALUES(3,1,-1,200901031130,2, 1,  -100,'adjustment','');
INSERT INTO "Transactions" VALUES(6,2,-1,200901060700,1, 1,100000,'salary','');
INSERT INTO "Transactions" VALUES(4,2, 1,200901041230,3,-1, -5000,'ATM'   ,'');
INSERT INTO "Transactions" VALUES(5,3,-1,200901051730,0, 1, -2100,'dental','');
CREATE TABLE Assets (key INTEGER PRIMARY KEY,name TEXT,type INTEGER,initialBalance REAL,sorder INTEGER);
INSERT INTO "Assets" VALUES(3,'Card',2,-10000,2);
INSERT INTO "Assets" VALUES(1,'Cash',0,  5000,0);
INSERT INTO "Assets" VALUES(2,'Bank',1,100000,1);
CREATE TABLE Categories (key INTEGER PRIMARY KEY,name TEXT,sorder INTEGER);
INSERT INTO "Categories" VALUES(2,'transport',0);
INSERT INTO "Categories" VALUES(1,'food',0);
INSERT INTO "Categories" VALUES(3,'medical',0);
COMMIT;
