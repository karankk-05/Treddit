-- Add up migration script here
begin;
drop table wishlist;
create table wishlist(
  email text not null,
  post_id int not null,
  FOREIGN KEY(email) REFERENCES login(email),
  FOREIGN KEY(post_id) REFERENCES posts(post_id),
  unique(email,post_id)
);
commit;
