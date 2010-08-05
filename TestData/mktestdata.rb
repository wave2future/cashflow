#!/usr/bin/ruby

MAX_ASSET = 4
MAX_CATEGORY = 5

def initTable
    puts "CREATE TABLE Transactions (key INTEGER PRIMARY KEY,asset INTEGER,dst_asset INTEGER,date DATE,type INTEGER,category INTEGER,value REAL,description TEXT,memo TEXT);"
    puts "CREATE TABLE Assets (key INTEGER PRIMARY KEY,name TEXT,type INTEGER,initialBalance REAL,sorder INTEGER);"
    puts "CREATE TABLE Categories (key INTEGER PRIMARY KEY,name TEXT,sorder INTEGER);"
end

def initAssets
    puts <<EOF
INSERT INTO "Assets" VALUES(1,'現金',0,7000.0,99999);
INSERT INTO "Assets" VALUES(2,'ABC銀行',1,500000.0,99999);
INSERT INTO "Assets" VALUES(3,'XYZカード',1,-30000.0,99999);
INSERT INTO "Assets" VALUES(4,'xxxカード',1,-20000.0,99999);
EOF
end

def initCategories
    puts <<EOF
INSERT INTO "Categories" VALUES(1,'食費',0);
INSERT INTO "Categories" VALUES(2,'交通費',1);
INSERT INTO "Categories" VALUES(3,'医療費',2);
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

    while (pkey < 1000)

        d = sprintf("%04d%02d%02d%02d%02d%02d", year, month, day, hour, min, sec);
        type = pkey % 3 + 1
        asset = pkey % MAX_ASSET + 1
        cat = pkey % MAX_CATEGORY + 1

        puts "INSERT INTO \"Transactions\" VALUES(#{pkey},#{asset},-1,#{d},#{type},#{cat},#{pkey*10.0},'hoge','xxx');"

        pkey += 1
    end
end


puts "BEGIN TRANSACTION;"
initTable
initAssets
initCategories
createTransactions
puts "COMMIT;"
