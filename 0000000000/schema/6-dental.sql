drop type if exists dental.hx CASCADE;
drop type if exists dental.dentalhx CASCADE;
drop type if exists dental.allergics CASCADE;
drop type if exists dental.medications CASCADE;
drop type if exists dental.xrays CASCADE;
drop type if exists dental.findings CASCADE;
drop type if exists dental.tx CASCADE;
drop type if exists dental.oh CASCADE;
drop type if exists dental.tmi CASCADE;
drop type if exists dental.crossbite CASCADE;
drop type if exists dental.visittype CASCADE;

drop type if exists dental.visitresult CASCADE;
drop type if exists dental.medical_history_form CASCADE;
drop type if exists dental.dental_history_form CASCADE;
drop type if exists dental.vital_sign_form CASCADE;
drop type if exists dental.xray_form CASCADE;
drop type if exists dental.intra_oral_exam_form CASCADE;
drop type if exists dental.finding_form CASCADE;
drop type if exists dental.print_info CASCADE;

drop type if exists dental.letter_info CASCADE;
drop type if exists dental.medcertificate_info CASCADE;
drop type if exists dental.docresult CASCADE;

drop table if exists dental.cctypes_pk_counter;
drop table if exists dental.cctypes;
drop table if exists dental.treatments;
drop table if exists dental.worksheets;
drop table if exists dental.txnotes;
drop table if exists dental.documents CASCADE;

drop function if exists dental.cctype_pk_next();
drop function if exists get_visitsbypatient(INTEGER);
drop function if exists get_documentsbypatient(INTEGER);
drop function if exists get_documentsbypatient(INTEGER,INTEGER);


drop schema if exists dental;
create schema dental;

--enums
CREATE TYPE dental.hx AS ENUM ('Cancer or tumor','Heart ailment or angina','Heart murmur, mitral valve prolapse, heart defect','Rheumatic fever or rheumatic heart disease','Artificial joint or valve','High or low blood pressure','Pacemaker','Tuberculosis or other lung problem','Kidney disease','Hepatitis or other liver disease','Alcoholism','Blood transfusion','Diabetes','Neurologic condition','Epilepsy, seizures, or fainting spells','Emotional condition','Arthritis','Herpes or cold sores','AIDS or HIV positive','Migraine headaches or frequent headaches','Anemia or blood disorders','Abnormal bleeding after extractions, surgery, or trauma','Hay fever or sinus trouble','Allergies or hives','Asthma');
CREATE TYPE dental.dentalhx AS ENUM ('Are you apprehensive about dental treatment?','Have you had problems with previous dental treatment?','Do you gag easily?','Do you wear dentures?','Does food catch between your teeth?','Do you have difficulty in chewing your foods?','Do you chew on only one side of your mouth?','Do you avoid brushing any part of your mouth b\c of pain?','Do your gums bleed easily?','Do your gums bleed when you floss?','Do your gums feel swollen or tender?','Have you ever noticed slow-healing sores in/about your mouth?','Are your teeth sensitive?','Do you feel twinges of pain with hot foods/liquids?','Do you feel twinges of pain with cold foods/liquids?','Do you feel twinges of pain in contact with sours?','Do you feel twinges of pain in contact with sweets?','Do you take fluoride supplements?','Are you dissatisfied with the appearance of your teeth?','Do you prefer to save your teeth?','Do you want complete dental care?','Does your jaw make noise so that it bothers you or others?','Do you clench or grind your jaws frequently?','Do you jaws ever feel tired?','Does your jaw get stuck so that you can''t open freely?','Does it hurt when you chew or open wide to take a bite?','Do you have any jaw symptoms or headaches upon awaking ?','Does jaw pain or discomfort affect your appetite, sleep,..?','Do you fond jaw pain or discomfort extremely frustrating?','Do you take medications or pills for pain or discomfort?','Do you have a temporomandibular (jaw) disorder (TMD)?','Do you have pain in the face, cheeks, jaw, joints, throat,..?','Are you unable to open your mouth as far as you want?','Are you aware of an uncomfortable bite?','Have you had a blow to the jaw (trauma)?','Are you a habitual gum chewer or pipe smoker?');
CREATE TYPE dental.allergics AS ENUM ('Latex materials','Penicillin or other antibiotics','Local anesthetics ("Novocain")','Codeine or other narcotics','Sulfa drugs','Barbiturates, sedatives, or sleeping pills','Aspirin');
CREATE TYPE dental.medications AS ENUM ('Aspirin','Anticoagulants (blood thinners)','Antibiotics or sulfa drugs','High blood pressure medicine','Antidepressants or tranquilizers','Insulin, Orinase, or other diabetes drug','nitroglycerin','Cortisone or other steroids','Osteoporosis (bone density) medicine');
CREATE TYPE dental.xrays AS ENUM ( 'Pano', 'BWx', 'FMS', 'PAx', 'Extraoral Photos', 'Intraoral');
CREATE TYPE dental.findings AS ENUM ('Gingivities / Periodontitis','Early-Stage Cavities','Cavities','Tooth Infection','Bruxism','TMD','Impacted Wisdom Teeth','Broken Tooth','Cracked Tooth','Dry Mouth (Xerostomia)','Soft Tissue');
CREATE TYPE dental.tx AS ENUM ('RCT','scaling','extraction');
CREATE TYPE dental.oh AS ENUM ('','Excellent','Good','Fair','Poor');
CREATE TYPE dental.tmi AS ENUM ('deviation','sounds','pain','ltd opening');
CREATE TYPE dental.crossbite AS ENUM ('R','L','');
CREATE TYPE dental.visittype AS ENUM ('New','Re-visit');

--composite type

CREATE TYPE dental.visitresult AS (
	date timestamptz,
	endat timestamptz,
	PatNumber int,
	seqno smallint,
  visittype dental.visittype,
  cc text,
  registerby text,
  printcount smallint
);
CREATE TYPE dental.vital_sign_form AS (
  bpmm numeric(13,2), --mmHg
  bphg numeric(13,2), 
  pulserate numeric(13,2)--beats/minutes
);
CREATE TYPE dental.medical_history_form AS (
	hxs dental.hx[],
  allergics dental.allergics[],
	medications dental.medications[],
	issmoke boolean,
  ispregnant boolean,
  deliverydate timestamptz,
  iscontraceptive boolean
);
CREATE TYPE dental.dental_history_form AS (
 hxs dental.dentalhx[],
 brush text,
 floss text,
 remark text
);
CREATE TYPE dental.xray_form AS (
  xrayexams dental.xrays[],
  teethno text,
  remark text
);
CREATE TYPE dental.intra_oral_exam_form AS (
  oh dental.oh,
  tmis dental.tmi[],
  molarclass text,
  overbite numeric(13,2),
  overjet numeric(13,2),
  midline numeric(13,2),
  crossbite dental.crossbite,
  mobilityno text,
  fremitus text,
  percussion text
);
CREATE TYPE dental.finding_form AS(
  findings dental.findings[],
  teethno text,
  remark text
);
CREATE TYPE dental.print_info AS (
  printcount smallint,
  lastprintby text,
  lastprintat timestamp without time zone
);
CREATE TYPE dental.docresult AS (
	examdate timestamptz,
	PatNumber int,
	seqno smallint,
  refno text,
  doctype text,
  registerby text,
  modifiedby text,
  printcount smallint
);
CREATE TYPE dental.letter_info AS (
    isMedicoLegal BOOLEAN,
	  body text
);
CREATE TYPE dental.medcertificate_info AS (
	  cc text,
    dx text,
    recomendation text,
    appointment text,
    sickleave text
);

--table
create table dental.treatments (
   seqno smallint not null,
   PatNumber int not null,
   startat timestamptz not null,
   endat   timestamptz,
   visittype dental.visittype,
   cc SMALLINT not null,
   hpi text,
   scanimg text,
	 vitalsign dental.vital_sign_form,   
   hx  dental.medical_history_form,
   dentalhx dental.dental_history_form,
   xrayexam dental.xray_form,
   xrayimages text[],

   ioe dental.intra_oral_exam_form,
   finding dental.finding_form,
   print dental.print_info, -- Print form
   
   registerby text,
	 registerat timestamptz not null default now(),
   lastmodifyby text,
	 lastmodifyat timestamptz
);
create table dental.worksheets(
  num smallint not null,
  seqno smallint not null,
  patnumber int not null,
	regdate timestamptz,
  toothno text,
  clincfinding text,
  radfinding text,
  txoption dental.tx,
  fee numeric(13,2),
  registerby text,
	registerat timestamptz not null default now()
);
create table dental.txnotes(
	num smallint not null,
  seqno smallint not null,
  patnumber int not null,
	regdate timestamptz,
  toothno text,
  proceduretype text, 
  registerby text,
	registerat timestamptz not null default now()
);
create table dental.documents (
   seqno smallint not null,
   PatNumber int not null,
   examdate timestamptz not null,
   refno text,
   doctype text,
   letter dental.letter_info,
   certificate dental.medcertificate_info,
   registerby text,
	 registerat timestamptz not null default now(),
   lastmodifyby text,
	 lastmodifyat timestamptz,
   print dental.print_info
);

CREATE TABLE dental.cctypes_pk_counter
(       
	cctype_pk int2
);
INSERT INTO dental.cctypes_pk_counter VALUES (0);
CREATE RULE noins_cctypes_pk AS ON INSERT TO dental.cctypes_pk_counter
DO NOTHING;
CREATE RULE nodel_only_cctypes_pk AS ON DELETE TO dental.cctypes_pk_counter
DO NOTHING;

CREATE OR REPLACE FUNCTION dental.cctype_pk_next()
returns int2 AS
$$
  DECLARE
   next_pk int2;
	BEGIN
     UPDATE dental.cctypes_pk_counter set cctype_pk = cctype_pk + 1;
     SELECT INTO next_pk cctype_pk from dental.cctypes_pk_counter;
     RETURN next_pk;
  END;
$$ LANGUAGE 'plpgsql';

create table dental.cctypes(
	id int2 DEFAULT dental.cctype_pk_next(), 
  name text,
  isactive boolean DEFAULT true,
  registerby text,
	registerat timestamptz not null default now()
);
CREATE RULE nodel_cctypes AS ON DELETE TO dental.cctypes
DO NOTHING;  

--FUNCTION
create or replace function dental.get_documentsbypatient(INTEGER)
returns setof dental.docresult
as $$
DECLARE
  patnum alias for $1; 
  outrow dental.docresult;
BEGIN
SET join_collapse_limit = 1;
	FOR outrow IN
with CTE_documents AS (
 select patnumber,seqno,examdate,refno,doctype,registerby,lastmodifyby,(print).printcount 
 from dental.documents
)
select t.examdate, t.patnumber,t.seqno, t.refno,t.doctype,t.registerby,t.lastmodifyby, t.printcount
from CTE_documents as t
where t.patnumber = patnum
ORDER BY t.examdate DESC
	LOOP
		RETURN NEXT outrow;
	END LOOP;
END;
$$ LANGUAGE PLPGSQL;

create or replace function dental.get_documentsbypatient(INTEGER, INTEGER)
returns setof dental.docresult
as $$
DECLARE
  patnum alias for $1; 
  seqnum alias for $2; 
  outrow dental.docresult;
BEGIN
SET join_collapse_limit = 1;
	FOR outrow IN
with CTE_documents AS (
 select patnumber,seqno,examdate,refno,doctype,registerby,lastmodifyby,(print).printcount 
 from dental.documents
)
select t.examdate, t.patnumber,t.seqno, t.refno,t.doctype,t.registerby,t.lastmodifyby, t.printcount
from CTE_documents as t
where t.patnumber = patnum and t.seqno=seqnum
	LOOP
		RETURN NEXT outrow;
	END LOOP;
END;
$$ LANGUAGE PLPGSQL;

create or replace function dental.get_visitsbypatient(INTEGER)
returns setof dental.visitresult
as $$
DECLARE
  patnum alias for $1; 
  outrow dental.visitresult;
BEGIN
SET join_collapse_limit = 1;
	FOR outrow IN
with CTE_Treatment AS (
 select patnumber,seqno,startat,endat,visittype,registerby,cc,(print).printcount 
 from dental.treatments
)
select t."startat" as "date", t.endat,t.patnumber,t.seqno, t.visittype,c.name as cc,t.registerby, t.printcount
from CTE_Treatment as t
LEFT JOIN dental.cctypes as c on t.cc = c.id
where t.patnumber = patnum
ORDER BY t."startat" DESC
	LOOP
		RETURN NEXT outrow;
	END LOOP;
END;
$$ LANGUAGE PLPGSQL;

CREATE INDEX index_dental_patients_on_treatment ON dental.treatments USING btree (seqno,PatNumber);
CREATE INDEX index_dental_patients_on_worksheet ON dental.worksheets USING btree (seqno,PatNumber);
CREATE INDEX index_dental_patients_on_txnote ON dental.txnotes USING btree (seqno,PatNumber);

drop type if exists core.patientappointmentresult CASCADE;
drop function if exists core.get_patientappointments(int);

create type core.patientappointmentresult AS(
   AppointedDate timestamp,
   Days SMALLINT,
   Reason text
);

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
