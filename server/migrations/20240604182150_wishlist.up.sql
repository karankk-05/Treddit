create table wishlist(
  wishlist_id int primary key generated always as identity,
  email text not null,
  post_id int not null,
  FOREIGN KEY(email) REFERENCES login(email),
  FOREIGN KEY(post_id) REFERENCES posts(post_id)
);
