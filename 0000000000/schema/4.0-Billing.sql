--TYPE
DROP TYPE if exists payment.item_view CASCADE;
DROP TYPE if EXISTS payment.orderstatus CASCADE;
DROP TYPE if exists payment.sale_view CASCADE;
DROP TYPE if exists payment.summary_view CASCADE;
DROP TABLE if exists payment.receives;
DROP TYPE if exists payment.receives CASCADE;
DROP TYPE if exists payment."status" CASCADE;
DROP TYPE if exists payment.creditsaleresult CASCADE;
DROP TYPE if exists payment.paymentorderresult CASCADE;
DROP TYPE if exists payment.paymentresult CASCADE;
DROP TYPE if exists payment.creditsaleresult CASCADE;
DROP TYPE if exists payment.dailysalesresult CASCADE;
--FUNCTION
DROP FUNCTION if exists payment.get_CountableItems(text, int, boolean);
DROP FUNCTION if exists payment.get_SearchableItems(text,int, boolean);
DROP FUNCTION if exists payment.get_SearchableItems(int, int, text,int, boolean);
DROP FUNCTION if exists payment.get_salesummary(date,date);
DROP FUNCTION if exists payment.get_totalholdsale(date,date,int,int,int,int,text,boolean,boolean,text);
DROP FUNCTION if exists payment.get_totalholdsale(date,date,int,int,int8,int8,text,boolean,boolean,text);
DROP FUNCTION if exists payment.get_totalvoidsale(date,date,int,int,int,int,text,boolean,boolean,text);
DROP FUNCTION if exists payment.get_totalvoidsale(date,date,int,int,int8,int8,text,boolean,boolean,text);
DROP FUNCTION if exists payment.get_totalsale(date,date,int,int,int,int,text,boolean,boolean,text);
DROP FUNCTION if exists payment.get_totalsale(date,date,int,int,int8,int8,text,boolean,boolean,text);
DROP FUNCTION if exists payment.get_searchable_sale(date,date,int,int,int,int,text,boolean,boolean,boolean,boolean,text);
DROP FUNCTION if exists payment.get_searchable_sale(date,date,int,int,int8,int8,text,boolean,boolean,boolean,boolean,text);
DROP FUNCTION if exists payment.get_countable_sale(date,date,int,int,int,int,text,boolean,boolean,boolean,boolean,text);
DROP FUNCTION if exists payment.get_countable_sale(date,date,int,int,int8,int8,text,boolean,boolean,boolean,boolean,text);
DROP FUNCTION if exists payment.array_sum(bigint);
DROP FUNCTION if exists payment.get_creditsales(date, date, text[], text);
DROP FUNCTION if exists payment.get_creditsalesbypatient(int4);
DROP FUNCTION if exists payment.get_payments(date, date);
DROP FUNCTION if exists payment.get_paymentordersbypatient(INTEGER);
DROP FUNCTION if exists payment.get_paymentorders(date,date,text,SMALLINT,payment.orderstatus[]);
DROP FUNCTION if exists payment.get_dailysalesamount(date,date);

--VIEW
DROP VIEW  if exists payment.salesreport;
--TABLE
DROP TABLE if exists payment.items_pk_counter;
DROP TABLE if exists payment.sales_pk_counter;
DROP TABLE if exists payment.orders_pk_counter;
DROP TABLE if exists payment.orderlines;
DROP TABLE if exists payment.orders;
DROP TABLE if exists payment.salelines;
DROP TABLE if exists payment.sales;
DROP TABLE if exists payment.categories;
DROP TABLE if exists payment.items;
DROP TABLE if exists payment.companyinfo;
DROP TABLE if exists payment.creditsales;

--FUNCTION
DROP FUNCTION if exists payment.item_pk_next();
DROP FUNCTION if exists payment.sale_pk_next();
DROP FUNCTION if exists payment.order_pk_next();

--TABLES

create table payment.categories(
	id smallint primary key not null,
  name text not null unique,
	active boolean default true
);
--INSERT INTO payment.categories VALUES (1,'Consultation'),(2,'Labratory'),(3,'Radiology'),(4,'Procedure'),(5,'Nursing care'),(6,'Medication'),(7,'Service'),(8,'Admission Fee');
INSERT INTO payment.categories VALUES 
(1,'Category 1'),
(2,'Category 2'),
(3,'Category 3'),
(4,'Category 4'),
(5,'Category 5'),
(6,'Category 6'),
(7,'Category 7'),
(8,'Category 8'),
(9,'Category 9'),
(10,'Category 10'),
(11,'Category 11'),
(12,'Category 12'),
(13,'Category 13'),
(14,'Category 14'),
(15,'Category 15'),
(16,'Category 16'),
(17,'Category 17'),
(18,'Category 18'),
(19,'Others');


CREATE TABLE payment.items_pk_counter
(       
	item_pk int2
);
INSERT INTO payment.items_pk_counter VALUES (0);
CREATE RULE noins_payitem_pk AS ON INSERT TO payment.items_pk_counter
DO NOTHING;
CREATE RULE nodel_only_payitem_pk AS ON DELETE TO payment.items_pk_counter
DO NOTHING;

CREATE OR REPLACE FUNCTION payment.item_pk_next()
returns int2 AS
$$
  DECLARE
   next_pk int2;
	BEGIN
     UPDATE payment.items_pk_counter set item_pk = item_pk + 1;
     SELECT INTO next_pk item_pk from payment.items_pk_counter;
     RETURN next_pk;
  END;
$$ LANGUAGE 'plpgsql';


CREATE TABLE payment.items (
  id int2 DEFAULT payment.item_pk_next(),
  code text not null,  
  name text not null,  
  itemcategory smallint not null,
  category text,
  price numeric(13,2) not null,
	price2 numeric(13,2) not null,
  active boolean not null default true,
	created_at timestamp without time zone NOT NULL,
  created_by text not null,
  updated_at timestamp without time zone,
  updated_by text,
  search_field tsvector not null,
  PRIMARY KEY(id)
);
CREATE RULE nodel_payitems AS ON DELETE TO payment.items
DO NOTHING; 

CREATE TRIGGER paymentitems_search_vector_refresh
BEFORE INSERT OR UPDATE ON payment.items
FOR EACH ROW EXECUTE PROCEDURE
tsvector_update_trigger(search_field, 'pg_catalog.english',  code, name, category);



--orders
CREATE TABLE payment.orders_pk_counter
(       
	order_pk int8
);
INSERT INTO payment.orders_pk_counter VALUES (0);
CREATE RULE noins_order_pk AS ON INSERT TO payment.orders_pk_counter
DO NOTHING;
CREATE RULE nodel_only_order_pk AS ON DELETE TO payment.orders_pk_counter
DO NOTHING;


CREATE OR REPLACE FUNCTION payment.order_pk_next()
returns int8 AS
$$
  DECLARE
   next_pk int8;
	BEGIN
     UPDATE payment.orders_pk_counter set order_pk = order_pk + 1;
     SELECT INTO next_pk order_pk from payment.orders_pk_counter;
     RETURN next_pk;
  END;
$$ LANGUAGE 'plpgsql';

CREATE TYPE payment.orderstatus AS ENUM ('pending','paid', 'void');

CREATE TABLE payment.orders(
  id int8 DEFAULT payment.order_pk_next(), -- Identifies the sales.
  "date" timestamp without time zone DEFAULT now(),
  patnumber int,
  cardno text,  
  patientname text,
  sex char(1),
  age text,
  saleid int8,
  receiveat timestamp without time zone,
  cashierid smallint,
  salepointid smallint,
  fsno text,
  salestax numeric(13,2),
  subtotal numeric(13,2),
  discount numeric(13,2),
	addition numeric(13,2),
	creditamount numeric(13,2),
	grandtotal numeric(13,2),
	remark text,
  status payment.orderstatus,
  registerby SMALLINT,
  registerat timestamp without time zone,
  CONSTRAINT order_pkey PRIMARY KEY (id)
);
CREATE RULE nodel_orders AS ON DELETE TO payment.orders
DO NOTHING;

CREATE TABLE payment.orderlines(
  seq smallint NOT NULL,
  ordernumber int8,
  itemid smallint,
	code text,  
	description text,
  category text,
  quantity real,
  unitprice numeric(13,2),
	addition numeric(13,2),
	discount numeric(13,2),
	creditamount numeric(13,2),
  CONSTRAINT orderlines_itemid_fkey FOREIGN KEY (itemid)
      REFERENCES payment.items (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE SET NULL,
  CONSTRAINT orderlines_ordernumber_fkey FOREIGN KEY (ordernumber)
      REFERENCES payment.orders (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE
);


--sale
CREATE TABLE payment.sales_pk_counter
(       
	sale_pk int8
);
-- Initialize table with one row on creation --
INSERT INTO payment.sales_pk_counter VALUES (0);
-- Disallow further insertions and deletions --
CREATE RULE noins_sale_pk AS ON INSERT TO payment.sales_pk_counter
DO NOTHING;
CREATE RULE nodel_only_sale_pk AS ON DELETE TO payment.sales_pk_counter
DO NOTHING;
-- Get next available sale_pk value from counter --
CREATE OR REPLACE FUNCTION payment.sale_pk_next()
returns int8 AS
$$
  DECLARE
   next_pk int8;
	BEGIN
     UPDATE payment.sales_pk_counter set sale_pk = sale_pk + 1;
     SELECT INTO next_pk sale_pk from payment.sales_pk_counter;
     RETURN next_pk;
  END;
$$ LANGUAGE 'plpgsql';


CREATE TABLE payment.sales(
  id int8 DEFAULT payment.sale_pk_next(), -- Identifies the sales.
  "date" timestamp without time zone,
  fsno text NOT NULL,
  patnumber int,
  cardno text,  
  patientname text,
  sex char(1),
  tin text,
  cashierid smallint,
  pharmacyid smallint,
  salestax numeric(13,2),
  subtotal numeric(13,2),
  discount numeric(13,2),
  grandtotal numeric(13,2),
  credittotal numeric(13,2),
  iscredit boolean DEFAULT false,
  isoutpatient boolean DEFAULT false,
  ishold boolean DEFAULT false,
  void boolean,
  voidby text,
  voiddate timestamp without time zone,
  recordat timestamp without time zone DEFAULT now(),
  remark text,
  CONSTRAINT sale_pkey PRIMARY KEY (id)
);
CREATE RULE nodel_sales AS ON DELETE TO payment.sales
DO NOTHING;
CREATE TABLE payment.salelines(
  seq smallint NOT NULL,
  salenumber int8,
  itemid smallint,
  name text,
  code text,
  itemcategory smallint not null,
  unit text,
  quantity real,
  unitprice numeric(13,2),
  CONSTRAINT salelines_itemid_fkey FOREIGN KEY (itemid)
      REFERENCES payment.items (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE SET NULL,
  CONSTRAINT salelines_salenumber_fkey FOREIGN KEY (salenumber)
      REFERENCES payment.sales (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE
);

CREATE TABLE payment.receives (
  seqno smallint NOT NULL DEFAULT 1,
	id int8,
  date timestamp without time zone,
  amount numeric(13,2),
  refno text,
  receiveby text not null ,
  receiveat timestamp without time zone not null DEFAULT  now(),
  remark text
);
CREATE TYPE payment.status AS ENUM ('1st-payment','on-paying', 'paid');
CREATE TABLE payment.creditsales(
  id int8, -- Identifies the sales.
  "date" timestamp without time zone,
  patnumber int,
  patientinfo text, --cardno, sex
  cashier text,
  salepoint text,
  total numeric(13,2),
  status payment.status NOT NULL DEFAULT '1st-payment'::payment.status,
  void boolean,
  voidby text,
  voiddate timestamp without time zone,
  remark text,
  search_field tsvector,
  CONSTRAINT salesettle_pkey PRIMARY KEY (id)
);

CREATE TRIGGER creditsale_search_vector_refresh
BEFORE INSERT OR UPDATE ON payment.creditsales
FOR EACH ROW EXECUTE PROCEDURE
tsvector_update_trigger(search_field, 'pg_catalog.english',  patientinfo);

-- select *
-- from payment.creditsales
-- where search_field  @@ to_tsquery('09113623:*')

--TYPE
CREATE TYPE payment.dailysalesresult AS (
  "date" date,
	totalsale numeric(13,2),
  credit numeric(13,2)
);
CREATE TYPE payment.paymentorderresult AS (
  id int8,
  "date" timestamp,
  patnumber int,
  cardno text,  
  patientname text,
  sex char(1),
  age text,
	orderedby text,  
	discount numeric(13,2),
  addition numeric(13,2),
	creditamount numeric(13,2),
	total numeric(13,2),
  cashier text,
	salespoint text,
  status payment.orderstatus,
  receiveat timestamp,
  remark text,
  fsno text
);
CREATE TYPE payment.item_view AS (
	id   SMALLINT,
  code text, 
  name text,
	itemcategory text,
  price numeric(13,2),
  price2 numeric(13,2),
	active boolean,
	createdat timestamp,
  createdby text,
  updatedat timestamp,
  updatedby text
);
CREATE TYPE payment.summary_view AS (
	name text,
	total numeric(13,2)
);
CREATE TYPE payment.sale_view AS (
	id int8,
  fsno text,
  ishold boolean,
  void boolean,
  date date,
  patnumber int,
  cardno text,  
  patientname text,
  sex char(1),
  cashier text,
  pharmacy text,
  voidby text,
  voiddate date,
  salestax numeric(13,2),
	subtotal numeric(13,2),
  grandtotal numeric(13,2),
	credittotal numeric(13,2),
  remark text
 );
CREATE TYPE payment.paymentresult AS (
  id int8,
  seqno smallint,
  "date" timestamp,
	refno text,  
	patientinfo text,
  amount numeric(13,2),
  receiveby text,
  receiveat timestamp,
  remark text
);
CREATE TYPE payment.creditsaleresult AS (
  id int8,
  "date" timestamp,
  orgid smallint,
  orgname text, 
  patnumber int,
  cardno text,
  patientname text,
  sex char(1),
  age text,
  phone text,
  cashier text,
  salepoint text,
  total numeric(13,2),
  paid numeric(13,2),
  status text,
  void boolean,
  remark text
);

--FUNCTION
create or replace function payment.get_SearchableItems( text,int, boolean)
returns setof payment.item_view
as $$
DECLARE 
	des alias for $1;
  cat alias for $2;
  isactive alias for $3;
	outitemview payment.item_view;
BEGIN
SET join_collapse_limit = 1;
	FOR outitemview IN
			SELECT
it."id",
it.code ,
it.name ,
CT.name AS itemcategory,
it.price,
it.price2,
it.active,
it.created_at as createdat,
it.created_by as createdby,
it.updated_at as updatedat,
it.updated_by as updatedby
FROM payment.items AS it
INNER JOIN payment.categories as ct on it.itemcategory = ct.id
 			where ((it."name" ILIKE des OR des IS NULL) AND
             (it."itemcategory" = cat OR cat IS NULL)) AND
 						 (it.active = isactive OR it.active = TRUE)
      ORDER BY it.code
	LOOP
		RETURN NEXT outitemview;
	END LOOP;
END;
$$ LANGUAGE PLPGSQL;

create or replace function payment.get_SearchableItems(int, int, text,int, boolean)
returns setof payment.item_view
as $$
DECLARE 
	inhowmany alias for $1;
	page alias for $2;
	des alias for $3;
  cat alias for $4;
  isactive alias for $5;
	outitemview payment.item_view;
BEGIN
SET join_collapse_limit = 1;
	FOR outitemview IN
			SELECT
it."id",
it.code ,
it.name ,
CT.name AS itemcategory,
it.price,
it.price2,
it.active,
it.created_at as createdat,
it.created_by as createdby,
it.updated_at as updatedat,
it.updated_by as updatedby
FROM payment.items AS it
INNER JOIN payment.categories as ct on it.itemcategory = ct.id
 			where ((it."name" ILIKE des OR des IS NULL) AND
             (it."itemcategory" = cat OR cat IS NULL)) AND
 						 (it.active = isactive OR it.active = TRUE)
      ORDER BY it.code
			limit inhowmany
			OFFSET page
	LOOP
		RETURN NEXT outitemview;
	END LOOP;
END;
$$ LANGUAGE PLPGSQL;

create or replace function payment.get_CountableItems(text, int, boolean)
returns setof int
as $$
DECLARE 
	des alias for $1;
	cat alias for $2;
	isactive alias for $3;
	total int;
BEGIN
		SELECT count(*)
		FROM payment.items as it
		into total
		where ((it."name" ILIKE des OR des IS NULL) AND
						(it."itemcategory" = cat OR cat IS NULL)) AND
						 (it.active = isactive OR it.active = TRUE);
		return query
		select total;
END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION payment.get_searchable_sale(date,date,int,int,int8,int8,text,boolean,boolean,boolean,boolean,text)
  RETURNS SETOF payment.sale_view AS
$$
DECLARE 
	fromdate alias for $1;
	todate alias for $2;
	store alias for $3;
  casher alias for $4;
	idfrom alias for $5;
	idto alias for $6;
	refno alias for $7;
	pattyp alias for $8;
  rectyp alias for $9;
	voidrec alias for $10;
  holdrec alias for $11;
  cno alias for $12;
	outsaleview payment.sale_view;
BEGIN
SET join_collapse_limit = 1;
	FOR outsaleview IN

SELECT
r."id",
r.fsno,
r.ishold,
r.void,
r."date",
r.patnumber,
r.cardno,
r.patientname,
r.sex,
"c".full_name AS cashier,
"p"."name" AS pharmacy,
r.voidby,
r.voiddate,
r.salestax,
r.subtotal,
r.grandtotal,
r.credittotal,
r.remark
FROM
payment.sales AS r
INNER JOIN membership.departments AS "p" ON r.pharmacyid = "p".id
INNER JOIN membership.users AS "c" ON "c".user_id = r.cashierid
where (r.fsno ILIKE refno OR refno IS NULL)  
      AND (r.cardno = cno OR cno IS NULL)  
			AND (r.pharmacyid = store OR store IS NULL)
      AND (r.cashierid = casher OR casher IS NULL)
			AND (r.date >= fromdate OR fromdate IS NULL)
			AND (r.date <= todate OR todate IS NULL)
			AND (r.id >= idfrom OR idfrom IS NULL)
			AND (r.id <= idto OR idto IS NULL)
			AND (r.isoutpatient = pattyp or pattyp IS NULL)
		  AND (r.iscredit = rectyp or rectyp IS NULL)
			AND (r.void = voidrec or voidrec IS NULL)
      AND (r.ishold = holdrec or holdrec IS NULL)
ORDER BY r."id" DESC			
	LOOP
		RETURN NEXT outsaleview;
	END LOOP;
END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION payment.get_countable_sale(date,date,int,int,int8,int8,text,boolean,boolean,boolean,boolean,text)
  RETURNS SETOF int8 AS
$$
DECLARE 
	fromdate alias for $1;
	todate alias for $2;
	store alias for $3;
  casher alias for $4;
	idfrom alias for $5;
	idto alias for $6;
	refno alias for $7;
	pattyp alias for $8;
  rectyp alias for $9;
	voidrec alias for $10;
  holdrec alias for $11;
  cno alias for $12;

	total int8;
BEGIN
		SELECT count(*) into total	
		FROM payment.sales AS r		
		where (r.fsno ILIKE refno OR refno IS NULL)  
      AND (r.cardno = cno OR cno IS NULL)  
			AND (r.pharmacyid = store OR store IS NULL)
      AND (r.cashierid = casher OR casher IS NULL)
			AND (r.date >= fromdate OR fromdate IS NULL)
			AND (r.date <= todate OR todate IS NULL)
			AND (r.id >= idfrom OR idfrom IS NULL)
			AND (r.id <= idto OR idto IS NULL)
			AND (r.isoutpatient = pattyp or pattyp IS NULL)
		  AND (r.iscredit = rectyp or rectyp IS NULL)
			AND (r.void = voidrec or voidrec IS NULL)
      AND (r.ishold = holdrec or holdrec IS NULL);
		return query
		select total;
END;
$$ LANGUAGE PLPGSQL;


CREATE OR REPLACE FUNCTION payment.get_totalsale(date,date,int,int,int8,int8,text,boolean,boolean,text)
  RETURNS SETOF numeric(13,2) AS
$$
DECLARE 
	fromdate alias for $1;
	todate alias for $2;
	store alias for $3;
  casher alias for $4;
	idfrom alias for $5;
	idto alias for $6;
	refno alias for $7;
	pattyp alias for $8;
  rectyp alias for $9;
cno alias for $10;  
total numeric(13,2);
BEGIN
		SELECT sum(grandtotal) into total	
		FROM payment.sales AS r		
		where (r.fsno ILIKE refno OR refno IS NULL) 
      AND (r.cardno = cno OR cno IS NULL)   
			AND (r.pharmacyid = store OR store IS NULL)
      AND (r.cashierid = casher OR casher IS NULL)
			AND (r.date >= fromdate OR fromdate IS NULL)
			AND (r.date <= todate OR todate IS NULL)
			AND (r.id >= idfrom OR idfrom IS NULL)
			AND (r.id <= idto OR idto IS NULL)
			AND (r.isoutpatient = pattyp or pattyp IS NULL)
		  AND (r.iscredit = rectyp or rectyp IS NULL);
		return query
		select total;
END;
$$ LANGUAGE PLPGSQL;


CREATE OR REPLACE FUNCTION payment.get_totalvoidsale(date,date,int,int,int8,int8,text,boolean,boolean,text)
  RETURNS SETOF numeric(13,2) AS
$$
DECLARE 
	fromdate alias for $1;
	todate alias for $2;
	store alias for $3;
  casher alias for $4;
	idfrom alias for $5;
	idto alias for $6;
	refno alias for $7;
	pattyp alias for $8;
  rectyp alias for $9;
  cno alias for $10;
	total numeric(13,2);
BEGIN
		SELECT sum(grandtotal) into total	
		FROM payment.sales AS r
		
		where (r.fsno ILIKE refno OR refno IS NULL)      
      AND (r.cardno = cno OR cno IS NULL) 
			AND (r.pharmacyid = store OR store IS NULL)
      AND (r.cashierid = casher OR casher IS NULL)
			AND (r.date >= fromdate OR fromdate IS NULL)
			AND (r.date <= todate OR todate IS NULL)
			AND (r.id >= idfrom OR idfrom IS NULL)
			AND (r.id <= idto OR idto IS NULL)
			AND (r.isoutpatient = pattyp or pattyp IS NULL)
		  AND (r.iscredit = rectyp or rectyp IS NULL)
			AND (r.void = true);
		return query
		select total;
END;
$$ LANGUAGE PLPGSQL;


CREATE OR REPLACE FUNCTION payment.get_totalholdsale(date,date,int,int,int8,int8,text,boolean,boolean,text)
  RETURNS SETOF numeric(13,2) AS
$$
DECLARE 
	fromdate alias for $1;
	todate alias for $2;
	store alias for $3;
  casher alias for $4;
	idfrom alias for $5;
	idto alias for $6;
	refno alias for $7;
	pattyp alias for $8;
  rectyp alias for $9;
  cno alias for $10;
	total numeric(13,2);
BEGIN
		SELECT sum(grandtotal) into total	
		FROM payment.sales AS r		
		where (r.fsno ILIKE refno OR refno IS NULL) 
      AND (r.cardno = cno OR cno IS NULL)   
			AND (r.pharmacyid = store OR store IS NULL)
      AND (r.cashierid = casher OR casher IS NULL)
			AND (r.date >= fromdate OR fromdate IS NULL)
			AND (r.date <= todate OR todate IS NULL)
			AND (r.id >= idfrom OR idfrom IS NULL)
			AND (r.id <= idto OR idto IS NULL)
			AND (r.isoutpatient = pattyp or pattyp IS NULL)
		    AND (r.iscredit = rectyp or rectyp IS NULL)
			AND (r.void IS NULL)
            AND (r.ishold = true);
		return query
		select total;
END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION payment.get_salesummary(date,date)
  RETURNS SETOF payment.summary_view AS
$$
DECLARE 
	fromdate alias for $1;
	todate alias for $2;
	outsummaryview payment.summary_view;
BEGIN
SET join_collapse_limit = 1;
	FOR outsummaryview IN
with cte_sales AS (
select *
from payment.sales
where (date >= fromdate OR fromdate IS NULL)
			AND (date <= todate OR todate IS NULL)
      AND (void = false or void IS NULL) 
   AND (ishold = false or ishold IS NULL))

select c."name" , sum(l.quantity * l.unitprice ) as total 
from cte_sales as s
INNER JOIN payment.salelines as l on l.salenumber = s.id
INNER JOIN payment.categories as c on c.id = l.itemcategory
GROUP BY   c.id,c."name"
ORDER BY c.id

	LOOP
		RETURN NEXT outsummaryview;
	END LOOP;
END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION payment.array_sum( paymentId int8) 
RETURNS DECIMAL AS $$
BEGIN
RETURN (SELECT sum(amount) as amount from payment.receives where id=paymentId);
END;
$$ LANGUAGE plpgsql;

create or replace function payment.get_creditsales(date,date,text[],text)
returns setof payment.creditsaleresult
as $$
DECLARE
  fromdate alias for $1; 
  todate alias for $2; 
  stat alias for $3;
  term alias for $4;
  outrow payment.creditsaleresult;
BEGIN
SET join_collapse_limit = 1;
	FOR outrow IN
with cte_creditsale as(
select *
from payment.creditsales)
select s.id,s.date,o.id as orgid, o.name as orgname,
s.patnumber,p.cardno, initcap(concat(p.firstname,' ',p.middlename,' ', p.lastname)) as patientname,
p.sex, replace(replace(replace(replace(replace(replace(age(CURRENT_DATE  , p.dob)::TEXT,' year','Y'),'Ys','Y'),' mons','M'),' mon','M'),' days','D'),' day','D') as age,
p.phone, s.cashier,s.salepoint,s.total,payment.array_sum(s.id) as paid, s.status,s.void,s.remark
from cte_creditsale as s
INNER JOIN core.patients as p on s.patnumber = p.patnumber
LEFT JOIN core.organization_patient as op on s.patnumber = op.patnumber
LEFT JOIN core.organizations as o on op.org_id = o.id

where  (date_ge(s.date::date,fromdate::date) and date_le(s.date::date,todate::date))
        AND (s.status::text LIKE ANY (stat))
				AND (search_field  @@ to_tsquery(term) OR term IS NULL)
ORDER BY id desc
	LOOP
		RETURN NEXT outrow;
	END LOOP;
END;
$$ LANGUAGE PLPGSQL;



create or replace function payment.get_creditsalesbypatient(int4)
returns setof payment.creditsaleresult
as $$
DECLARE
  patno alias for $1; 
  outrow payment.creditsaleresult;
BEGIN
SET join_collapse_limit = 1;
	FOR outrow IN
with cte_creditsale as(
select *
from payment.creditsales)
select s.id,s.date,o.id as orgid, o.name as orgname, s.patnumber,p.cardno, initcap(concat(p.firstname,' ',p.middlename,' ', p.lastname)) as patientname,
p.sex, replace(replace(replace(replace(replace(replace(age(CURRENT_DATE  , p.dob)::TEXT,' year','Y'),'Ys','Y'),' mons','M'),' mon','M'),' days','D'),' day','D') as age,
p.phone, s.cashier,s.salepoint,s.total,payment.array_sum(s.id) as paid, s.status,s.void,s.remark
from cte_creditsale as s
INNER JOIN core.patients as p on s.patnumber = p.patnumber
LEFT JOIN core.organization_patient as op on s.patnumber = op.patnumber
LEFT JOIN core.organizations as o on op.org_id = o.id
where  s.patnumber = patno
ORDER BY id desc
	LOOP
		RETURN NEXT outrow;
	END LOOP;
END;
$$ LANGUAGE PLPGSQL;

create or replace function payment.get_payments(date,date)
returns setof payment.paymentresult
as $$
DECLARE
  fromdate alias for $1; 
  todate alias for $2; 
  outrow payment.paymentresult;
BEGIN
SET join_collapse_limit = 1;
	FOR outrow IN

select r.id, r.seqno, r.date, r.refno,s.patientinfo,r.amount,r.receiveby,r.receiveat,r.remark  
from payment.receives as r
INNER JOIN payment.creditsales as s on s.id = r.id
where  (s.void <> true or  s.void is null) and (date_ge(r.date::date,fromdate::date) and date_le(r.date::date,todate::date))
       AND (r.remark <> '1st Advance Payment')
ORDER BY r.date DESC
	LOOP
		RETURN NEXT outrow;
	END LOOP;
END;
$$ LANGUAGE PLPGSQL;


create or replace function payment.get_paymentordersbypatient(INTEGER)
returns setof payment.paymentorderresult
as $$
DECLARE
  patnum alias for $1; 
  outrow payment.paymentorderresult;
BEGIN
SET join_collapse_limit = 1;
	FOR outrow IN
SELECT o.id,o."registerat" as "date",o.patnumber,o.cardno,o.patientname,
o.sex,o.age,u.full_name as orderedby,o.discount,o.addition,o.creditamount,o.grandtotal as total,
c.full_name as cashier, s.name as salespoint,o.status,o.receiveat,o.remark,o.fsno
 from payment.orders as o
INNER JOIN membership.users as u on o.registerby = u.user_id
LEFT JOIN  membership.users as c on o.cashierid = u.user_id
LEFT JOIN membership.departments as s on o.salepointid = s.id
where o.patnumber = patnum
ORDER BY o."registerat" DESC
	LOOP
		RETURN NEXT outrow;
	END LOOP;
END;
$$ LANGUAGE PLPGSQL;

create or replace function payment.get_paymentorders(date,date,text,SMALLINT,payment.orderstatus[])
returns setof payment.paymentorderresult
as $$
DECLARE
  fromdate alias for $1; 
	todate alias for $2;
  searchterm alias for $3;
  orderby alias for $4; 
  stat alias for $5; 
  outrow payment.paymentorderresult;
BEGIN
SET join_collapse_limit = 1;
	FOR outrow IN
SELECT o.id,o."registerat" as "date",o.patnumber,o.cardno,o.patientname,
o.sex,o.age,u.full_name as orderedby,o.discount,o.addition,o.creditamount,o.grandtotal as total,
c.full_name as cashier, s.name as salespoint,o.status,o.receiveat,o.remark,o.fsno
 from payment.orders as o
INNER JOIN membership.users as u on o.registerby = u.user_id
LEFT JOIN  membership.users as c on o.cashierid = u.user_id
LEFT JOIN membership.departments as s on o.salepointid = s.id
where (date_ge(o."registerat"::date,fromdate::date) and date_le(o."registerat"::date,todate::date))
			AND ((lower(o.cardno) like searchterm OR searchterm IS NULL )
          OR (lower(o.patientname) like searchterm OR searchterm IS NULL  ))
      AND (o.registerby = orderby OR orderby IS NULL)
      AND (o.status::payment.orderstatus = ANY (array[stat]))
ORDER BY o."registerat" DESC
	LOOP
		RETURN NEXT outrow;
	END LOOP;
END;
$$ LANGUAGE PLPGSQL;

create or replace function payment.get_dailysalesamount(date,date)
returns setof payment.dailysalesresult
as $$
DECLARE
  fromdate alias for $1; 
  todate alias for $2; 
  outrow payment.dailysalesresult;
BEGIN
SET join_collapse_limit = 1;
	FOR outrow IN
		
    WITH cte_sale as (
		SELECT void, date::DATE, sum(grandtotal) as total, sum(credittotal) as credit
		FROM payment.sales
		GROUP by void, date::DATE
		union ALL
		select null::BOOLEAN as void, date::DATE, sum(amount) as total, 0 as credit 
		from payment.receives

		GROUP by void,remark, date::DATE
		having remark <> '1st Advance Payment'
		),
		void_sale as (
		SELECT total
		FROM cte_sale
		where void = true)
		select date, sum(total) as totalsale, sum(credit) as credit
		from cte_sale
		GROUP by date,void
		HAVING void is null and (date_ge(date::date,fromdate::date) and date_le(date::date,todate::date))
		ORDER BY date asc

	LOOP
		RETURN NEXT outrow;
	END LOOP;
END;
$$ LANGUAGE PLPGSQL;


