create table if not exists user_reports (
  report_id int generated always as identity,
  email text,
  accused text,
  statement text,
  open_timestamp timestamp default (timezone('utc', now())) not null,

  PRIMARY KEY(report_id),
  foreign key(email) references users(email),
  foreign key(accused) references users(email)
);
