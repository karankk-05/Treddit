create table if not exists post_reports (
  email text,
  statement text,
  post_id int,
  open_timestamp timestamp default (timezone('utc', now())) not null,

  foreign key(email) references users(email),
  foreign key(post_id) references posts(post_id)
);
