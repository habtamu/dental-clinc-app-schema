create table articles (id serial, title varchar, content text);
create table articles_w_tags (tags text[]) inherits (articles);
create table articles_wo_tags () inherits (articles);


insert into articles_wo_tags (title, content)
    values ('Title 1', 'Content 1'),
           ('Title 2', 'Content 2');
insert into articles_w_tags (title, content, tags)
    values ('Title 3', 'Content 3', '{"tag_1", "tag_2"}'::text[]),
           ('Title 4', 'Content 4', '{"tag_2", "tag_3"}'::text[]);