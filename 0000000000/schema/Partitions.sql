 
CREATE TABLE hashvalue_PT
(
  hash bytea NOT NULL,
  hashtime timestamp without time zone NOT NULL
);

--Create Partition with check rule for validation
CREATE TABLE hashvalue_PT_y2008m01 (
CHECK ( hashtime >= DATE '2008-01-01' AND hashtime < DATE '2008-01-31' )
 ) INHERITS (hashvalue_PT);
 CREATE TABLE hashvalue_PT_y2008m02 (
CHECK ( hashtime >= DATE '2008-02-01' AND hashtime < DATE '2008-02-29' )
 ) INHERITS (hashvalue_PT);
CREATE TABLE hashvalue_PT_y2008m03 (
CHECK ( hashtime >= DATE '2008-03-01' AND hashtime < DATE '2008-03-31' )
 ) INHERITS (hashvalue_PT);
CREATE TABLE hashvalue_PT_y2008m04 (
CHECK ( hashtime >= DATE '2008-04-01' AND hashtime < DATE '2008-04-30' )
 ) INHERITS (hashvalue_PT);
CREATE TABLE hashvalue_PT_y2008m05 ( 
CHECK ( hashtime >= DATE '2008-05-01' AND hashtime < DATE '2008-05-31' )
) INHERITS (hashvalue_PT);
CREATE TABLE hashvalue_PT_y2008m06 ( 
CHECK ( hashtime >= DATE '2008-06-01' AND hashtime < DATE '2008-06-30' )
) INHERITS (hashvalue_PT);
CREATE TABLE hashvalue_PT_y2008m07 ( 
CHECK ( hashtime >= DATE '2008-07-01' AND hashtime < DATE '2008-07-31' )
) INHERITS (hashvalue_PT);
CREATE TABLE hashvalue_PT_y2008m08 ( 
CHECK ( hashtime >= DATE '2008-08-01' AND hashtime < DATE '2008-08-31' )
) INHERITS (hashvalue_PT);
CREATE TABLE hashvalue_PT_y2008m09 ( 
CHECK ( hashtime >= DATE '2008-09-01' AND hashtime < DATE '2008-09-30' )
) INHERITS (hashvalue_PT);
CREATE TABLE hashvalue_PT_y2008m010 ( 
CHECK ( hashtime >= DATE '2008-10-01' AND hashtime < DATE '2008-10-31' )
) INHERITS (hashvalue_PT);


ALTER TABLE hashvalue_PT_y2008m01 ADD CONSTRAINT hashvalue_PT_y2008m01_pkey PRIMARY KEY (hashtime, hash);
ALTER TABLE hashvalue_PT_y2008m02 ADD CONSTRAINT hashvalue_PT_y2008m02_pkey PRIMARY KEY (hashtime, hash);
ALTER TABLE hashvalue_PT_y2008m03 ADD CONSTRAINT hashvalue_PT_y2008m03_pkey PRIMARY KEY (hashtime, hash);
ALTER TABLE hashvalue_PT_y2008m04 ADD CONSTRAINT hashvalue_PT_y2008m04_pkey PRIMARY KEY (hashtime, hash);
ALTER TABLE hashvalue_PT_y2008m05 ADD CONSTRAINT hashvalue_PT_y2008m05_pkey PRIMARY KEY (hashtime, hash);
ALTER TABLE hashvalue_PT_y2008m06 ADD CONSTRAINT hashvalue_PT_y2008m06_pkey PRIMARY KEY (hashtime, hash);
ALTER TABLE hashvalue_PT_y2008m07 ADD CONSTRAINT hashvalue_PT_y2008m07_pkey PRIMARY KEY (hashtime, hash);
ALTER TABLE hashvalue_PT_y2008m08 ADD CONSTRAINT hashvalue_PT_y2008m08_pkey PRIMARY KEY (hashtime, hash);
ALTER TABLE hashvalue_PT_y2008m09 ADD CONSTRAINT hashvalue_PT_y2008m09_pkey PRIMARY KEY (hashtime, hash);
ALTER TABLE hashvalue_PT_y2008m010 ADD CONSTRAINT hashvalue_PT_y2008m010_pkey PRIMARY KEY (hashtime, hash);

CREATE INDEX idx_hashvalue_PT_y2008m01_hashtime ON hashvalue_PT_y2008m01 (hashtime);
CREATE INDEX idx_hashvalue_PT_y2008m02_hashtime ON hashvalue_PT_y2008m02 (hashtime);
CREATE INDEX idx_hashvalue_PT_y2008m03_hashtime ON hashvalue_PT_y2008m03 (hashtime);
CREATE INDEX idx_hashvalue_PT_y2008m04_hashtime ON hashvalue_PT_y2008m04 (hashtime);
CREATE INDEX idx_hashvalue_PT_y2008m05_hashtime ON hashvalue_PT_y2008m05 (hashtime);
CREATE INDEX idx_hashvalue_PT_y2008m06_hashtime ON hashvalue_PT_y2008m06 (hashtime);
CREATE INDEX idx_hashvalue_PT_y2008m07_hashtime ON hashvalue_PT_y2008m07 (hashtime);
CREATE INDEX idx_hashvalue_PT_y2008m08_hashtime ON hashvalue_PT_y2008m08 (hashtime);
CREATE INDEX idx_hashvalue_PT_y2008m09_hashtime ON hashvalue_PT_y2008m09 (hashtime);
CREATE INDEX idx_hashvalue_PT_y2008m010_hashtime ON hashvalue_PT_y2008m010 (hashtime);

==============================================================================================================

CREATE TABLE orders (
     id            INT NOT NULL,
     address       TEXT NOT NULL,
     order_date    TIMESTAMP NOT NULL
);

CREATE TABLE orders_part_2011 (
    CHECK (order_date >= DATE '2011-01-01'
                    AND order_date < DATE '2012-01-01')
 
) INHERITS (orders);
 
CREATE TABLE orders_part_2010 (
    CHECK (order_date < DATE '2011-01-01')
) INHERITS (orders);

CREATE INDEX orders_part_2011_idx ON orders_part_2011(order_date);
CREATE INDEX orders_part_2010_idx ON orders_part_2010(order_date);

==============================================================================================================

create table logs (
   created_at timestamp without time zone default now(),
   content text);


