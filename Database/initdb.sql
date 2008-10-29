CREATE TABLE Assets (
        key INTEGER PRIMARY KEY,
        type INTEGER,   /* 0:Cash, 1:Bank account, 2:Credit Card, 99:Other */
        name TEXT UNIQUE);

CREATE TABLE Transactions (
        key INTEGER PRIMARY KEY,
        date DATE,
        type INTEGER,   /* 0:Outgo, 1:Income, 2:Adjustment, 3:Move */
        value REAL,
        balance REAL,
        description TEXT,
        memo TEXT,
        asset INTEGER,  /* key of Assets */
        asset_dest INTEGER,  /* key of Assets (destination for move) */
        category INTEGER /* key of category */
);

CREATE TABLE Category (
        key INTEGER PRIMARY KEY,
        sorder INTEGER,      /* sort order */
        type INTEGER,   /* same as type of Transactions */
        name TEXT UNIQUE);
