begin;
create table if not exists categories(
  category text primary key unique
);
alter table posts add column category text;
alter table posts add constraint category_log foreign key(category) references categories(category);
commit;
