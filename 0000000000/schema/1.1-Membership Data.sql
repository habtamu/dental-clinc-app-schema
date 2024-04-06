-- INSERT
-- user groups (System Admin, Reception, Nurse/Doctor, LabTechnicians, Radiologists)
insert into membership.departments(name,isStore) 
values('Reception',false);

insert into membership.users(user_name, full_name, password,user_group,is_administrator) values ('admin', 'Administrator',md5('1'),'System Admin', true);
---Patient
insert into membership.operations(operation_id,description) values(2,'[Patient] Can add new patient?');
insert into membership.operations(operation_id,description) values(3,'[Patient] Can edit existing patient?');
insert into membership.operations(operation_id,description) values(4,'[Patient] Can remove existing patient?');
--Item Price
insert into membership.operations(operation_id,description) values(5,'[Item Price] Can view item price?');
insert into membership.operations(operation_id,description) values(6,'[Item Price] Can add new item price?');
insert into membership.operations(operation_id,description) values(7,'[Item Price] Can edit existing item price?');
insert into membership.operations(operation_id,description) values(8,'[Item Price] Can remove/revert existing item price?');
-- Invoice
insert into membership.operations(operation_id,description) values(9,'[Sale] Can register sale invoice?');
insert into membership.operations(operation_id,description) values(10,'[Sale] Editable item unit price?');
insert into membership.operations(operation_id,description) values(11,'[Sale] Can show sales amount information?');
insert into membership.operations(operation_id,description) values(12,'[Sale] Can export sales report?');

insert into membership.operations(operation_id,description) values(13,'[Payment Order] Can view payment orders?');
insert into membership.operations(operation_id,description) values(14,'[Payment Order] Can receive payment on payment orders?');

--Credit settlement
insert into membership.operations(operation_id,description) values(21,'[Advance Payment] Can view payment settlement page?');
insert into membership.operations(operation_id,description) values(22,'[Advance Payment] Can register payment?');
insert into membership.operations(operation_id,description) values(23,'[Advance Payment] Can edit/modify registered payment?');
insert into membership.operations(operation_id,description) values(24,'[Advance Payment] Can remove/delete registered payment?');
insert into membership.operations(operation_id,description) values(25,'[Advance Payment] Can view registered payment?');

insert into membership.operations(operation_id,description) values(70,'[Look up] Can maintain lookup setting?');

insert into membership.operations(operation_id,description) values(99,'[Printing] Can export or print treatment report?');--
insert into membership.operations(operation_id,description) values(100,'[Email] Can email sales report?');
-- SELECT
select * from membership.users;
