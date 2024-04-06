drop TYPE if exists membership.groups CASCADE;
drop table if exists membership.permissions;
drop table if exists membership.user_logins;
drop trigger if exists users_search_vector_refresh on membership.users;
drop table if exists membership.users;
drop table if exists membership.departments;
drop table if exists membership.operations;



CREATE TYPE membership.groups AS ENUM ('Front Desk', 'Doctor','Nurse','Laboratory','Radiology','System Admin','Finance');

-- update membership.users set user_group = null;
-- alter table membership.users alter column user_group type membership.groups
-- USING
-- user_group::membership.groups,
-- ALTER COLUMN user_group SET DEFAULT 'Front Desk';
 
-- CREATE TABLE

create table membership.departments(
	id smallserial primary key not null,
	name text not null,
  isStore boolean default false,
  isDispensary boolean default false,
  isstoreunit boolean default false,
  isActive boolean default true
);

create table membership.users(
	user_id smallserial primary key not null,
	user_name text unique not null,
	full_name text,
	password text not null,
  user_group membership.groups DEFAULT 'Front Desk'::membership.groups,
	is_active boolean default true,
	is_administrator boolean default false,
	search_field tsvector,
  current_signin_at timestamptz,
	last_signin_at  timestamptz,
	signin_count int,	
	created_at timestamptz not null default now()
);
create table membership.user_logins (
	id serial primary key not null,
  user_id int not null references membership.users(user_id) on delete cascade,
	current_signin_at timestamptz,
	last_signin_at  timestamptz,
  ip inet
);
create table membership.operations(
	operation_id SMALLINT primary key not null,
	description text not null
);
create table membership.permissions(
	user_id SMALLINT not null references membership.users(user_id) on delete cascade,
	operation_id SMALLINT not null references membership.operations(operation_id) on delete cascade,
  is_permitted boolean DEFAULT false,
	primary key (user_id, operation_id)
);

CREATE TRIGGER users_search_vector_refresh
BEFORE INSERT OR UPDATE ON membership.users
FOR EACH ROW EXECUTE PROCEDURE
tsvector_update_trigger(search_field, 'pg_catalog.english',  user_name, full_name);

