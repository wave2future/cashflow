CREATE TABLE Transactions (
        key INTEGER PRIMARY KEY,
        asset INTEGER,
        date DATE,
        type INTEGER,
        value REAL,
        balance REAL,
        description TEXT,
        memo TEXT);

CREATE TABLE Assets (
        key INTEGER PRIMARY KEY,
        type INTEGER,
        name TEXT);


