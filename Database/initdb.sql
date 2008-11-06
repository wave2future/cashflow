CREATE TABLE Assets (
        key INTEGER PRIMARY KEY,
        type INTEGER,   /* 0:Cash, 1:Bank account, 2:Credit Card, 99:Other */
        name TEXT UNIQUE,
        initialBalance REAL,
        sorder INTEGER);

CREATE TABLE Transactions (
        key INTEGER PRIMARY KEY,
        asset INTEGER,  /* key of Assets */
        date DATE,
        type INTEGER,   /* 0:Outgo, 1:Income, 2:Adjustment, 3:Move */
        category INTEGER, /* key of category */
        value REAL,
        description TEXT,
        memo TEXT
);

CREATE TABLE Category (
        key INTEGER PRIMARY KEY,
        sorder INTEGER,      /* sort order */
        type INTEGER,   /* same as type of Transactions */
        name TEXT UNIQUE);
