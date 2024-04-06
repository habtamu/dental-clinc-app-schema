CREATE TABLE sampletable (x numeric);
INSERT INTO sampletable
         SELECT random() * 10000
         FROM generate_series(1, 1000000);
CREATE INDEX idx_x ON sampletable(x);

explain SELECT * FROM sampletable WHERE x = 42353;

explain SELECT * FROM sampletable WHERE x < 42353;

explain SELECT * FROM sampletable WHERE x < 423;