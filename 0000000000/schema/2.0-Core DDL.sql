--DROP
--assignments

drop table if EXISTS core.trials ;
drop table if exists core.assignments CASCADE;
drop table if exists core.assignments_pk_counter CASCADE;
drop function if exists core.assignment_pk_next();
drop type if exists core.vwassignment CASCADE;
DROP TYPE if exists core.summary_view CASCADE;
DROP FUNCTION if exists core.get_assignmentsummary(date,date);
drop function if exists core.get_assignments(date,date);

--end assignment
--organization
DROP FUNCTION if exists core.organizations_pk_next() CASCADE;
DROP TABLE if exists core.organizations_pk_counter;
DROP TABLE if exists core.organizations;
DROP TABLE if exists core.organization_patient;

DROP TYPE if exists core.sponsor_view CASCADE;
DROP FUNCTION if exists core.get_searchablesponsors(text,int);
DROP FUNCTION if exists core.get_searchablesponsors(int, int, text,int);
DROP FUNCTION if exists core.get_countablesponsors(text,int);

--end organization

drop table if exists core.patientlogs_pk_counter;
drop table if exists core.appointments_pk_counter;
drop table if exists core.patients_pk_counter;
drop table if exists core.config;
drop table if exists core.appointments;
drop table if exists core.audit;
drop table if exists core.patientlogs;
drop table if exists core.patientnames;
drop table if exists core.patients;

drop function if exists core.patientlog_pk_next();
drop function if exists core.appointment_pk_next();
drop function if exists core.patient_pk_next();

drop function if exists core.get_appointments(date);
drop function if exists core.get_appointments(date,date);
drop function if exists core.get_patientlogs(date,date);
drop function if exists core.get_todaypatient(text);
drop function if exists core.get_patientlogs(date,date);
drop function if exists core.get_todaypatientno(text);
drop type if exists core.temppatient_view;
drop function if exists core.get_countable_patient(text,text,text,text,text,int4);
drop function if exists core.get_searchable_patient(int4, int4,text,text,text,text,text,int4);

drop type if exists core.patientappointmentresult CASCADE;
drop function if exists core.get_patientappointments(int);

drop type if exists core.reasons; 
drop type if exists core.patientlog_view; 
drop type if exists core.temppatient_view;
drop type if exists core.patient_view;
drop type if exists core.vwappointment;

drop table if exists core.appointments;
drop table if exists core.patients;
drop table if exists core.patientstoday;
drop table if exists core.patientlogs;

--TYPE
CREATE TYPE core.reasons AS ENUM ('First visit','Follow-up','Procedure');
create type core.patientappointmentresult AS(
   AppointedDate timestamp,
   Days SMALLINT,
   Reason text
);

--TABLES
CREATE TABLE core.appointments_pk_counter
(       
	appointment_pk int8
);
INSERT INTO core.appointments_pk_counter VALUES (0);
CREATE RULE noins_appointment_pk AS ON INSERT TO core.appointments_pk_counter
DO NOTHING;
CREATE RULE nodel_only_appointment_pk AS ON DELETE TO core.appointments_pk_counter
DO NOTHING;
CREATE OR REPLACE FUNCTION core.appointment_pk_next()
returns int8 AS
$$
  DECLARE
   next_pk int8;
	BEGIN
     UPDATE core.appointments_pk_counter set appointment_pk = appointment_pk + 1;
     SELECT INTO next_pk appointment_pk from core.appointments_pk_counter;
     RETURN next_pk;
  END;
$$ LANGUAGE 'plpgsql';


CREATE TABLE core.patients_pk_counter
(       
	patient_pk int4
);
INSERT INTO core.patients_pk_counter VALUES (0);
CREATE RULE noins_patient_pk AS ON INSERT TO core.patients_pk_counter
DO NOTHING;
CREATE RULE nodel_only_patient_pk AS ON DELETE TO core.patients_pk_counter
DO NOTHING;
CREATE OR REPLACE FUNCTION core.patient_pk_next()
returns int4 AS
$$
  DECLARE
   next_pk int4;
	BEGIN
     UPDATE core.patients_pk_counter set patient_pk = patient_pk + 1;
     SELECT INTO next_pk patient_pk from core.patients_pk_counter;
     RETURN next_pk;
  END;
$$ LANGUAGE 'plpgsql';


CREATE TABLE core.patientlogs_pk_counter
(       
	patientlog_pk int8
);
INSERT INTO core.patientlogs_pk_counter VALUES (0);
CREATE RULE noins_patientlog_pk AS ON INSERT TO core.patientlogs_pk_counter
DO NOTHING;
CREATE RULE nodel_only_patientlog_pk AS ON DELETE TO core.patientlogs_pk_counter
DO NOTHING;
CREATE OR REPLACE FUNCTION core.patientlog_pk_next()
returns int8 AS
$$
  DECLARE
   next_pk int8;
	BEGIN
     UPDATE core.patientlogs_pk_counter set patientlog_pk = patientlog_pk + 1;
     SELECT INTO next_pk patientlog_pk from core.patientlogs_pk_counter;
     RETURN next_pk;
  END;
$$ LANGUAGE 'plpgsql';

create table core.trials (
   counter  date unique 
);


create table core.config (
   userid SMALLINT PRIMARY KEY,
   body jsonb
);
create table core.patientnames (
   Name  text unique 
);

create table core.appointments (
   id int8 DEFAULT core.appointment_pk_next(),--id int8 DEFAULT core.appointment_pk_next(),
   RegistrationDate timestamp without time zone NOT NULL default now(),
   PatNumber int not null ,
	 CardNo text not null,
	 Name text not null,
   Age SMALLINT,
   Sex char(1),
   Phone text,
   regionid smallint,
   subcityid smallint,
	 AppointedDate timestamp without time zone NOT NULL,
   Days SMALLINT not null,
   reason core.reasons,   
   appointedbyid smallint,
   remark text,
   createdby text,
   PRIMARY key(id)
	 
);
CREATE RULE nodel_appointments AS ON DELETE TO core.appointments
DO NOTHING; 

 

create table core.patientlogs (
   id int8 DEFAULT core.patientlog_pk_next(), --id int8 DEFAULT core.patientlog_pk_next(),
   RegistrationDate timestamp without time zone NOT NULL default now(),
   PatNumber int not null ,
	 CardNo text not null,
	 Name text not null,
   Age SMALLINT,
   Sex char(1),
   IsNew boolean DEFAULT true,
   Phone text,
   regionid smallint,
   subcityid smallint,
   Address text,
	 status int2 DEFAULT 1,   
	 createdby text,
	 modifiedby text,
   PRIMARY key(id)
);
CREATE RULE nodel_patientlogs AS ON DELETE TO core.patientlogs
DO NOTHING; 


create table core.patientstoday (
   PatNumber int PRIMARY KEY not null ,
	 CardNo text not null,
	 Name text not null,
   sex char(1),
   phone text,
   dob date,
   status "char" NOT NULL DEFAULT 'N'::"char",
	 active int2 DEFAULT 1,
   createdat timestamp without time zone NOT NULL default now()
);

create table core.patients (
   PatNumber int4 DEFAULT core.patient_pk_next() , --PatNumber int4 DEFAULT core.patient_pk_next(),
	 RegistrationDate date not null,
   CardNo text not null,
	 FirstName text not null,
   MiddleName text not null,
   LastName text,
   FullNameAm text,
	 Sex char(1) DEFAULT 'M',
	 DoB date,
   Phone text,
	 Address text,
   regionid smallint,
   subcityid smallint,
   status int2 DEFAULT 1, -- 0 Inactive, 1 Active
	 modifiedby text,
   modifiedat timestamp without time zone NOT NULL default now(),
   PRIMARY key(PatNumber)
 --created_at timestamp without time zone NOT NULL
 --updated_at timestamp without time zone NOT NULL
);
ALTER TABLE core.patients ADD CONSTRAINT card_unique UNIQUE (CardNo);
CREATE RULE nodel_patients AS ON DELETE TO core.patients
DO NOTHING; 

--alter sequence core.patients_PatNumber_seq RESTART WITH 45626;
CREATE TABLE core.audit (
	event_time timestamp NOT NULL,
	user_name text NOT NULL,
	operation text NOT NULL,
	table_name text NOT NULL,
	old_row json,
	new_row json
);

--TRIGGER
CREATE OR REPLACE FUNCTION core.audit_trigger()
RETURNS TRIGGER AS $$
BEGIN
IF (TG_OP = 'DELETE') THEN
INSERT INTO core.audit
VALUES (CURRENT_TIMESTAMP, CURRENT_USER,TG_OP,
TG_TABLE_NAME, row_to_json(OLD), null);
RETURN OLD;
ELSIF (TG_OP = 'UPDATE') THEN
INSERT INTO core.audit
VALUES (CURRENT_TIMESTAMP, CURRENT_USER,TG_OP,
TG_TABLE_NAME, row_to_json(OLD), row_to_json(NEW));
RETURN NEW;
END IF;
RETURN NULL;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER audit_trigger
AFTER UPDATE OR INSERT OR DELETE
ON core.patients
FOR EACH ROW
EXECUTE PROCEDURE core.audit_trigger();


-- INDEX
CREATE INDEX index_patients_on_Phone ON core.patients USING btree (Phone);
CREATE INDEX index_patients_on_CardNo ON core.patients USING btree (CardNo);
CREATE INDEX index_patients_on_FirstName ON core.patients USING btree (FirstName);
CREATE INDEX index_patients_on_MiddleName ON core.patients USING btree (MiddleName);
CREATE UNIQUE INDEX index_patients_on_id ON core.patients USING btree (PatNumber);


CREATE TABLE core.assignments_pk_counter
(       
	assignment_pk int8
);
INSERT INTO core.assignments_pk_counter VALUES (0);
CREATE RULE noins_assignment_pk AS ON INSERT TO core.assignments_pk_counter
DO NOTHING;
CREATE RULE nodel_only_assignment_pk AS ON DELETE TO core.assignments_pk_counter
DO NOTHING;
CREATE OR REPLACE FUNCTION core.assignment_pk_next()
returns int8 AS
$$
  DECLARE
   next_pk int8;
	BEGIN
     UPDATE core.assignments_pk_counter set assignment_pk = assignment_pk + 1;
     SELECT INTO next_pk assignment_pk from core.assignments_pk_counter;
     RETURN next_pk;
  END;
$$ LANGUAGE 'plpgsql';

create table core.assignments (
   id int8 DEFAULT core.assignment_pk_next(),
   Date timestamp without time zone NOT NULL,
   PatNumber int not null ,
	 CardNo text not null,
	 Name text not null,
   Age SMALLINT,
   Sex char(1),
   assignedto smallint,
   remark text,
   createdby text,
   PRIMARY key(id)
	 
);
CREATE RULE nodel_assignments AS ON DELETE TO core.assignments
DO NOTHING; 

--core.organizations
CREATE TABLE core.organizations_pk_counter
(       
	organization_pk int2
);
INSERT INTO core.organizations_pk_counter VALUES (0);
CREATE RULE noins_organization_pk AS ON INSERT TO core.organizations_pk_counter
DO NOTHING;
CREATE RULE nodel_only_organization_pk AS ON DELETE TO core.organizations_pk_counter
DO NOTHING;
CREATE OR REPLACE FUNCTION core.organizations_pk_next()
returns int2 AS
$$
  DECLARE
   next_pk int2;
	BEGIN
     UPDATE core.organizations_pk_counter set organization_pk = organization_pk + 1;
     SELECT INTO next_pk organization_pk from core.organizations_pk_counter;
     RETURN next_pk;
  END;
$$ LANGUAGE 'plpgsql';
create table core.organizations(
	id int2 DEFAULT core.organizations_pk_next(),
  name text not null unique,
	active boolean default true
);
CREATE TABLE core.organization_patient (
  org_id int2,
  patnumber int4, 
	created_at timestamp without time zone NOT NULL DEFAULT now(),
  created_by text not null,
  PRIMARY KEY(org_id,patnumber)
);


--TYPE
create type core.vwappointment AS
(
   id bigint ,
   RegistrationDate timestamp,
   PatNumber int,
	 CardNo text,
	 Name text,
   Age SMALLINT,
   Sex char(1),
   Phone text,
   Region text,
   Subcity  text,
	 AppointedDate timestamp,
	 Days SMALLINT,
	 Reason text,
   Remark text, 
   createdby text,
   appointedby text
);
create type core.patientlog_view AS
(
   id bigint ,
   RegistrationDate timestamp,
   PatNumber int,
	 CardNo text,
	 Name text,
   Age SMALLINT,
   Sex char(1),
   IsNew boolean,
   Phone text,
   regionid smallint,
   Region text,
   subcityid smallint,
   Subcity  text,
	 Address text,
   createdby text,
	 modifiedby text
);
create type core.patient_view AS
(
   PatNumber int,
   RegistrationDate date,	 
   CardNo text,
   PatName text,
	 Sex char(1),
	 Age text,
   Phone text,
   Region text,
   Subcity  text,
   address  text,
	 status int2,
	 modifiedby text,
   modifiedat timestamptz
);
create type core.temppatient_view AS
(
   PatNumber int,
   --RegistrationDate date,
   CardNo text,
   Name text,
   sex char(1),
   phone text,
   doB date,
   age text,
	 Status char(1),
	 Used int
);
create type core.vwassignment AS
(
   id bigint ,
   date timestamp,
   patnumber int,
	 cardno text,
	 name text,
   age SMALLINT,
   sex char(1),
   assignedto text,
   remark text, 
   createdby text
);
CREATE TYPE core.summary_view AS (
	name text,
	total int
);
CREATE TYPE core.sponsor_view AS (
  orgid int2,
  patnumber int4, 
	cardno text, 
  patname text,
	org   text,
	createdat timestamp,
  createdby text
);

--FUNCTION
create or replace function core.get_searchable_patient(int4, int4,text,text,text,text,text,int4)
returns setof core.patient_view
as $$
DECLARE 
	inhowmany alias for $1;
	page alias for $2;
	cno alias for $3;
  pno alias for $4;
  fname alias for $5;
  mname alias for $6;
  lname alias for $7;
	statustype alias for $8;
	outpatient core.patient_view;
BEGIN
SET join_collapse_limit = 1;
FOR outpatient IN
SELECT p.PatNumber,p.RegistrationDate,p.CardNo,  initcap(concat(p.firstname,' ',p.middlename,' ', p.lastname,' ', p.FullNameAm)) as PatName,p.Sex,
replace(replace(replace(replace(replace(replace(age(CURRENT_DATE  , p.dob)::TEXT,' year','Y'),'Ys','Y'),' mons','M'),' mon','M'),' days','D'),' day','D') as age ,
p.Phone,r."name" as Region,  initcap(c."name") as Subcity,initcap(p.Address), p.status,p.modifiedby,p.modifiedat
FROM core.patients as p
LEFT OUTER JOIN lookup.regions as r on p.regionid = r."id"
LEFT OUTER JOIN lookup.subcities as c on p.subcityid = c."id"
where (p.CardNo ILIKE cno OR cno IS NULL) AND  
      (p.Phone ILIKE pno OR pno IS NULL) AND
			(p.FirstName ILIKE fname OR fname IS NULL) AND
			(p.MiddleName ILIKE mname OR mname IS NULL) AND
			(p.LastName ILIKE lname OR lname IS NULL) AND
            (p.status = statustype)
ORDER BY p.PatNumber desc

			limit inhowmany
			OFFSET page

	LOOP
		RETURN NEXT outpatient;
	END LOOP;
END;
$$ LANGUAGE PLPGSQL;

create or replace function core.get_countable_patient(text,text,text,text,text,int4)
returns setof bigint
as $$
DECLARE 
	cno alias for $1;
  pno alias for $2;
  fname alias for $3;
  mname alias for $4;
  lname alias for $5;
  statustype alias for $6;

	total bigint;
BEGIN
		SELECT count(*)
		into total
		FROM core.patients	
    where (CardNo ILIKE cno OR cno IS NULL) AND  
      (Phone ILIKE pno OR pno IS NULL) AND
			(FirstName ILIKE fname OR fname IS NULL) AND
			(MiddleName ILIKE mname OR mname IS NULL) AND
			(LastName ILIKE lname OR lname IS NULL) AND
      (status = statustype);
		return query
		select total;
END;
$$ LANGUAGE PLPGSQL;


create or replace function core.get_todaypatient(text)
returns setof core.temppatient_view
as $$
DECLARE 
  term alias for $1;
	outpatient core.temppatient_view;
BEGIN
	FOR outpatient IN
SELECT p.PatNumber, p.CardNo, initcap(p.Name) as Name, p.sex,p.phone,p.doB, 
replace(replace(replace(replace(replace(replace(age(CURRENT_DATE  , p.dob)::TEXT,' year','Y'),'Ys','Y'),' mons','M'),' mon','M'),' days','D'),' day','D') as age ,
p.Status,date_mi(now()::date,createdat::date) as Used
FROM core.patientstoday as p
where ((p.CardNo ILIKE term OR term IS NULL) OR
      (p.name ILIKE term OR term IS NULL)) AND
      (p.active = 1)
ORDER BY p.createdat desc
	LOOP
		RETURN NEXT outpatient;
	END LOOP;
END;
$$ LANGUAGE PLPGSQL;

create or replace function core.get_todaypatientno(text)
returns setof bigint
as $$
DECLARE 
	term alias for $1;
	total bigint;
BEGIN
		SELECT count(*)
		into total
		FROM core.patientstoday	
    where (CardNo ILIKE term OR term IS NULL) OR 
       (name ILIKE term OR term IS NULL);
		return query
		select total;
END;
$$ LANGUAGE PLPGSQL;



create or replace function core.get_patientlogs(date,date)
returns setof core.patientlog_view
as $$
DECLARE 
	fromdate alias for $1;
	todate alias for $2;
	outpatient core.patientlog_view;
BEGIN
	FOR outpatient IN

SELECT p.id,p.RegistrationDate,p.PatNumber,p.CardNo, initcap(p.Name) as Name, p.Age, 
p.Sex,p.IsNew, P.Phone, p.regionid,initcap(r.name) as region, p.subcityid, initcap(c.name) as Subcity,initcap(p.Address) as Address,p.createdby,p.modifiedby
FROM core.patientlogs as p
inner join lookup.regions as r on p.regionid = r.id 
left JOIN lookup.subcities as c on p.subcityid = c.id 
where (date_ge(p.RegistrationDate::date,fromdate::date) 
      and date_le(p.RegistrationDate::date,todate::date)) AND 
      (p.status = 1)
ORDER BY p.Id desc
	LOOP
		RETURN NEXT outpatient;
	END LOOP;
END;
$$ LANGUAGE PLPGSQL;


create or replace function core.get_appointments(date)
returns setof core.vwappointment
as $$
DECLARE 
	appointat alias for $1;
	outpatient core.vwappointment;
BEGIN
	FOR outpatient IN

SELECT p.id,p.RegistrationDate,p.PatNumber,p.CardNo, initcap(p.Name) as Name, p.Age, 
p.Sex,P.Phone, r.name as region, initcap(c.name) as Subcity,p.AppointedDate,p.Days,p.Reason,p.Remark, p.createdby, u.full_name as appointedby
FROM core.appointments as p
inner join lookup.regions as r on p.regionid = r.id 
left JOIN lookup.subcities as c on p.subcityid = c.id 
left JOIN membership.users as u on p.appointedbyid = u.user_id 
where date_ge(p.AppointedDate::date,appointat::date) 
      and date_le(p.AppointedDate::date,appointat::date)
ORDER BY p.AppointedDate
	LOOP
		RETURN NEXT outpatient;
	END LOOP;
END;
$$ LANGUAGE PLPGSQL;


create or replace function core.get_appointments(date,date)
returns setof core.vwappointment
as $$
DECLARE 
	appointfrom alias for $1;
  appointto alias for $2;
	outpatient core.vwappointment;
BEGIN
SET join_collapse_limit = 1;
	FOR outpatient IN

SELECT p.id,p.RegistrationDate,p.PatNumber,p.CardNo, initcap(p.Name) as Name, p.Age, 
p.Sex,P.Phone, r.name as region, initcap(c.name) as Subcity,p.AppointedDate,p.Days,p.Reason,p.Remark, p.createdby, u.full_name as appointedby
FROM core.appointments as p
inner join lookup.regions as r on p.regionid = r.id 
left JOIN lookup.subcities as c on p.subcityid = c.id 
left JOIN membership.users as u on p.appointedbyid = u.user_id 
where date_ge(p.AppointedDate::date,appointfrom::date) 
      and date_le(p.AppointedDate::date,appointto::date)
ORDER BY p.AppointedDate
	LOOP
		RETURN NEXT outpatient;
	END LOOP;
END;
$$ LANGUAGE PLPGSQL;

create or replace function core.get_patientappointments(int)
returns setof core.patientappointmentresult
as $$
DECLARE 
	patno alias for $1;
  outappoin core.patientappointmentresult;
BEGIN
SET join_collapse_limit = 1;
	FOR outappoin IN
SELECT AppointedDate,Days,Reason
FROM core.appointments
where (PatNumber = patno)
ORDER BY AppointedDate desc
	LOOP
		RETURN NEXT outappoin;
	END LOOP;
END;
$$ LANGUAGE PLPGSQL;

create or replace function core.get_assignments(date,date)
returns setof core.vwassignment
as $$
DECLARE 
	assignfrom alias for $1;
  assignto alias for $2;
	outassignrow core.vwassignment;
BEGIN
SET join_collapse_limit = 1;
	FOR outassignrow IN

SELECT p.id,p.Date,p.PatNumber,p.CardNo, initcap(p.Name) as Name, p.Age, p.Sex,u.full_name as appointedby,p.Remark, p.createdby
FROM core.assignments as p
left JOIN membership.users as u on p.assignedto = u.user_id 
where date_ge(p.Date::date,assignfrom::date) 
      and date_le(p.Date::date,assignto::date)
ORDER BY p.Date
	LOOP
		RETURN NEXT outassignrow;
	END LOOP;
END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION core.get_assignmentsummary(date,date)
  RETURNS SETOF core.summary_view AS
$$
DECLARE 
	fromdate alias for $1;
	todate alias for $2;
	outsummaryview core.summary_view;
BEGIN
SET join_collapse_limit = 1;
	FOR outsummaryview IN
with cte_assigns AS (
select Date,assignedto
from core.assignments
where date_ge(date::date,fromdate::date) 
      and date_le(date::date,todate::date))
select u.full_name as name, count(*) as total  
from cte_assigns as a
INNER JOIN membership.users as u on u.user_id = a.assignedto
GROUP BY   u.full_name
ORDER BY count(*) desc
	LOOP
		RETURN NEXT outsummaryview;
	END LOOP;
END;
$$ LANGUAGE PLPGSQL;


create or replace function core.get_searchablesponsors(text,int)
returns setof core.sponsor_view
as $$
DECLARE 
	fname alias for $1;
  companyid alias for $2;
  outsponsorrow core.sponsor_view;
BEGIN
SET join_collapse_limit = 1;
	FOR outsponsorrow IN
with cte_sponsors AS
(
SELECT s.org_id as orgid,s.patnumber, p.cardno , initcap(concat(p.firstname,' ',p.middlename,' ', p.lastname,' ', p.FullNameAm)) as PatName,
      o.name as org, s.created_at as createdat, s.created_by as createdby
FROM core.organization_patient AS s
INNER JOIN core.organizations as o on s.org_id = o.id
INNER JOIN core.patients as p on s.patnumber = p.patnumber
)
select * from cte_sponsors
where ((patname ILIKE fname OR fname IS NULL) AND
             (orgid = companyid OR companyid IS NULL))
      ORDER BY patname
	LOOP
		RETURN NEXT outsponsorrow;
	END LOOP;
END;
$$ LANGUAGE PLPGSQL;

create or replace function core.get_countablesponsors(text,int)
returns setof int
as $$
DECLARE 
	fname alias for $1;
  companyid alias for $2;
	total int;
BEGIN
with cte_sponsors AS
(
SELECT s.org_id, p.cardno , initcap(concat(p.firstname,' ',p.middlename,' ', p.lastname)) as PatName,
      o.name as org, s.created_at as createdat, s.created_by as createdby
FROM core.organization_patient AS s
INNER JOIN core.organizations as o on s.org_id = o.id
INNER JOIN core.patients as p on s.patnumber = p.patnumber
)

		SELECT count(*)
		FROM cte_sponsors as s
		into total
		where ((patname ILIKE patname OR patname IS NULL) AND
						(org_id = companyid OR companyid IS NULL));
		return query
		select total;
END;
$$ LANGUAGE PLPGSQL;

create or replace function core.get_searchablesponsors(int, int, text,int)
returns setof core.sponsor_view
as $$
DECLARE 
	inhowmany alias for $1;
	page alias for $2;
	fname alias for $3;
  companyid alias for $4;
  outsponsorrow core.sponsor_view;
BEGIN
SET join_collapse_limit = 1;
	FOR outsponsorrow IN
			with cte_sponsors AS
(
SELECT s.org_id  as orgid,s.patnumber, p.cardno , initcap(concat(p.firstname,' ',p.middlename,' ', p.lastname,' ', p.FullNameAm)) as PatName,
      o.name as org, s.created_at as createdat, s.created_by as createdby
FROM core.organization_patient AS s
INNER JOIN core.organizations as o on s.org_id = o.id
INNER JOIN core.patients as p on s.patnumber = p.patnumber
)
select * from cte_sponsors
where ((patname ILIKE fname OR fname IS NULL) AND
             (orgid = companyid OR companyid IS NULL))
      ORDER BY patname
			limit inhowmany
			OFFSET page

	LOOP
		RETURN NEXT outsponsorrow;
	END LOOP;
END;
$$ LANGUAGE PLPGSQL;


