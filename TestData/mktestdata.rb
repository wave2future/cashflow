#!/usr/bin/ruby

def initTable
    puts "CREATE TABLE Transactions (key INTEGER PRIMARY KEY,asset INTEGER,dst_asset INTEGER,date DATE,type INTEGER,category INTEGER,value REAL,description TEXT,memo TEXT);"
    puts "CREATE TABLE Assets (key INTEGER PRIMARY KEY,name TEXT,type INTEGER,initialBalance REAL,sorder INTEGER);"
    puts "CREATE TABLE Categories (key INTEGER PRIMARY KEY,name TEXT,sorder INTEGER);"
end

def initAssets
    puts <<EOF
INSERT INTO "Assets" VALUES(1,'現金',0,7000.0,99999);
INSERT INTO "Assets" VALUES(2,'ABC銀行',1,500000.0,99999);
EOF
end

def initCategories
    puts <<EOF
INSERT INTO "Categories" VALUES(1,'食費',0);
INSERT INTO "Categories" VALUES(2,'交通費',1);
EOF
end

def createTransactions
    pkey = 1
    asset = 1
    year = 2010
    month = 8
    day = 1
    hour = 12
    min = 0
    sec = 0

    while (pkey < 

    puts "INSERT INTO \"Transactions\" VALUES(1,2,1,201004010236,3,-1,-20000.0,'ATM','');"
end


puts "BEGIN TRANSACTION;"
initTable
initAssets
initCategories
createTransactions
puts "COMMIT;"
