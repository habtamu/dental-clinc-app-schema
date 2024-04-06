--TABLES
create table lookup.regions(
	id smallint primary key not null,
  name varchar(25) not null unique
);
INSERT INTO lookup.regions VALUES 
(1,'AA'),
(2,'Afar'),
(3,'Amhara'),
(4,'Benishangul Gumuz'),
(5,'Dire Dawa'),
(6,'Gambella'),
(7,'Harari'),
(8,'Oromia'),
(9,'Somali'),
(10,'SNNPR'),
(11,'Tigray');

create table lookup.subcities(
	id smallint primary key not null,
  name varchar(25) not null unique
);
INSERT INTO lookup.subcities VALUES (1,'N/Lafto'),(2,'Addis Ketema'),(3,'Akaki/Kaliti'),(4,'Arada'),(5,'Bole'),(6,'Gulele'),(7,'Kirkos'),(8,'K/Keraniyo'),(9,'Lideta'),(10,'Yeka'),(11,'-');
