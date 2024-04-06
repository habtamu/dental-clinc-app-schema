--TABLES
create table lookup.regions(
	id smallint primary key not null,
  name varchar(25) not null unique
);
INSERT INTO lookup.regions VALUES 
(0,'Mekelle'),
(1,'Tigray'),
(2,'Afar'),
(3,'Amhara'),
(4,'Benishangul Gumuz'),
(5,'Dire Dawa'),
(6,'Gambella'),
(7,'Harari'),
(8,'Oromia'),
(9,'Somali'),
(10,'SNNPR'),
(11,'AA');

create table lookup.subcities(
	id smallint primary key not null,
  name varchar(25) not null unique
);
INSERT INTO lookup.subcities VALUES 
(1,'Addi Haqi'),
(2,'Ayder'),
(3,'Haddinet'),
(4,'Hawelti'),
(5,'Qedamay Weyyane'),
(6,'Kwiha'),
(7,'Semien'),
(8,'-');
