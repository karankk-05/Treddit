begin;
alter table posts drop column category;
drop table if exists categories;
commit;
