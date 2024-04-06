--upsert
CREATE TABLE upsert_test (
    id SERIAL NOT NULL PRIMARY KEY,
    type int4 NOT NULL,
    number int4 NOT NULL,
    name text NOT NULL
);

ALTER TABLE upsert_test ADD CONSTRAINT upsert_test_unique UNIQUE (type, number);

INSERT INTO upsert_test (type, number, name) VALUES (1, 1, 'Name 3') ON CONFLICT DO NOTHING;
--INSERT 0 0

-- If there is conflict on unique constraint on columns type and number, update conflicted row with new name
INSERT INTO upsert_test (type, number, name) VALUES (1, 1, 'Name 3') ON CONFLICT (type, number) DO UPDATE SET name = EXCLUDED.name;
--INSERT 0 1

INSERT INTO upsert_test (type, number, name) VALUES (1, 1, 'Name 3') ON CONFLICT (type, number) DO UPDATE SET name = EXCLUDED.name WHERE type = 1;

--UPDATE multiple columns from SELECT sub-query
UPDATE executors ex
SET (full_name, role) = (
  SELECT em.name, em.role
  FROM employee em
  WHERE em.employee_id = ex.employee_id
);


---- indexing application
-------------
create table t_btree(id int, info text);
insert into t_btree select generate_series(1,10000), md5(random()::text) ;  
create index idx_t_btree_1 on t_btree using btree (id);  
explain (analyze,verbose,timing,costs,buffers) select * from t_btree where id=1;  

--------------
create table t_hash (id int, info text);  
insert into t_hash select generate_series(1,100), repeat(md5(random()::text),10000);  
create index idx_t_hash_1 on t_hash using hash (info); 
set enable_hashjoin=on;  
explain (analyze,verbose,timing,costs,buffers) select * from t_hash where info in (select info from t_hash limit 1); 
-----------------------

create table t_gin1 (id int, arr int[]); 

do language plpgsql $$  
declare  
 begin  
   for i in 1..10000 loop  
      insert into t_gin1 select i, array(select random()*1000 from generate_series(1,10));  
   end loop;  
 end;  
$$;  

create index idx_t_gin1_1 on t_gin1 using gin (arr);
explain (analyze,verbose,timing,costs,buffers) select * from t_gin1 where arr && array[1,2];  
-------------------------------------------------

create extension btree_gin;  

create table t_gin2 (id int, c1 int);  

insert into t_gin2 select generate_series(1,100000), random()*10 ;

create index idx_t_gin2_1 on t_gin2 using gin (c1); 

explain (analyze,verbose,timing,costs,buffers) select * from t_gin2 where c1=1;  

-----------------------------------------------

create table t_gin3 (id int, c1 int, c2 int, c3 int, c4 int, c5 int, c6 int, c7 int, c8 int, c9 int);  
insert into t_gin3 select generate_series(1,100000), random()*10, random()*20, random()*30, random()*40, random()*50, random()*60, random()*70, random()*80, random()*90; 
create index idx_t_gin3_1 on t_gin3 using gin (c1,c2,c3,c4,c5,c6,c7,c8,c9);  

explain (analyze,verbose,timing,costs,buffers) select * from t_gin3 where c1=1 or c2=1 and c3=1 or c4=1 and (c6=1 or c7=2) or c8=9 or c9=10;

--------------------------------------------------

create table t_gist (id int, pos point);  
insert into t_gist select generate_series(1,100000), point(round((random()*1000)::numeric, 2), round((random()*1000)::numeric, 2));  

select * from t_gist  limit 3;  

create index idx_t_gist_1 on t_gist using gist (pos); 

explain (analyze,verbose,timing,costs,buffers) select * from t_gist where circle '((100,100) 10)'  @> pos; 

---------------------------------------------------
--Sorting with a scale index

create extension btree_gist;  
create index idx_t_btree_2 on t_btree using gist(id);  
explain (analyze,verbose,timing,costs,buffers) select * from t_btree order by id <-> 100 limit 1;  

----------------------------------------------------

--Searching with a range index
create table t_spgist (id int, rg int4range);  
insert into t_spgist select id, int4range(id, id+(random()*200)::int) from generate_series(1,100000) t(id); 

set maintenance_work_mem ='1GB';  

create index idx_t_spgist_1 on t_spgist using spgist (rg);  

explain (analyze,verbose,timing,costs,buffers) select * from t_spgist where rg && int4range(1,100);  

--------------------------------------------------------

create table t_brin (id int, info text, crt_time timestamp); 
insert into t_brin select generate_series(1,1000000), md5(random()::text), clock_timestamp();  

---------------------------------------------------

CREATE FUNCTION validate_event_availability() returns trigger as $$
      DECLARE
        events_count int;
      BEGIN
        events_count := (SELECT COUNT(*) FROM events WHERE (
          events.calendar_id = NEW.calendar_id AND events.begins_at < NEW.finishes_at AND events.finishes_at > NEW.begins_at AND events.id != NEW.id
        ));
        IF (events_count != 0) THEN
          RAISE EXCEPTION 'Period between % and % is already taken', NEW.begins_at, NEW.finishes_at;
        END IF;
        RETURN NEW;
      END;
      $$ language plpgsql;

      CREATE TRIGGER validate_event_availability_trigger BEFORE INSERT OR UPDATE ON events
      FOR EACH ROW EXECUTE PROCEDURE validate_event_availability();

--------------- CTE for DATA INSERT 
create extension if not exists pgcrypto;

create table orders(
  id serial primary key, 
  key uuid unique default gen_random_uuid(),
  email text not null, 
  total decimal(10,2),
  created_at timestamptz default now()  
);

create table order_items(
  id serial primary key,
  order_id int not null references orders(id) on delete cascade,
  sku text not null,
  price decimal(10,2) not null,
  quantity int not null default 1,
  discount decimal(10,2) not null default 0
);

create table downloads(
  id serial primary key,
  key uuid unique not null default gen_random_uuid(),
  order_id int not null references orders(id) on delete cascade,
  order_item_id int not null references order_items(id) on delete cascade,
  times_downloaded int not null default 0
);

create table products(
  id serial primary key not null,
  sku text unique not null,
  name text not null,
  price decimal(10,2) not null,
  created_at timestamptz not null default now()
);

insert into products(sku, name, price)
values
('imposter-single','The Imposter''s Handbook', 30.00),
('mission-interview','Mission:Interview',49.00);

--SAVING ORDER DATA TRANSACTIONALLY
with new_order as(
  insert into orders(email, total) 
  values ('rob@bigmachine.io',100.00) 
  returning *
), new_items as (
  insert into order_items(order_id, sku, price)
  select new_order.id, 'imposter-single',30.00
  from new_order
  returning *
)
select * from new_items;

--CREATING DOWNLOADS FROM OUR NEW ORDER
with new_order as(
  insert into orders(email, total) 
  values ('rob@bigmachine.io',100.00) 
  returning *
), new_items as (
  insert into order_items(order_id, sku, price)
  select new_order.id, 'imposter-single',30.00
  from new_order
  returning *
), new_downloads as (
  insert into downloads(order_id, order_item_id)
  select new_order.id, new_items.id 
  from new_order, new_items
  returning *
)

select * from new_downloads;

--INSERTING MULTIPLE ORDER ITEMS
with new_order as(
  insert into orders(email, total) 
  values ('rob@bigmachine.io',100.00) 
  returning *
), new_items as (
  insert into order_items(order_id, sku, price)
  (
    select new_order.id, sku,price
    from products, new_order
    where sku in('imposter-single','mission-interview')
  )
  returning *
), new_downloads as (
  insert into downloads(order_id, order_item_id)
  select new_order.id, new_items.id 
  from new_order, new_items
  returning *
)
select * from new_downloads;



prepare new_order(text, decimal(10,2), text[]) as
with new_order as(
  insert into orders(email, total) 
  values ($1,$2) 
  returning *
), new_items as (
  insert into order_items(order_id, sku, price)
  (
    select new_order.id, sku,price
    from products, new_order
    where sku = any($3)
  )
  returning *
), new_downloads as (
  insert into downloads(order_id, order_item_id)
  select new_order.id, new_items.id 
  from new_order, new_items
  returning *
)
select * from new_downloads;

execute new_order('rob@bigmachine.io',100.00, '{imposter-single,mission-interview}')
