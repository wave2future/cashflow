#!/bin/sh
rm test.db
sqlite3 test.db < initdb.sql
sqlite3 test.db < testdata.sql

