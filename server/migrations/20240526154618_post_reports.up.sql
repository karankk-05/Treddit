create table if not exists post_reports (
  report_id int generated always as identity,
  email text,
  statement text,
  post_id int,
  open_timestamp timestamp default (timezone('utc', now())) not null,

  PRIMARY KEY(report_id),
  foreign key(email) references users(email),
  foreign key(post_id) references posts(post_id)
);
