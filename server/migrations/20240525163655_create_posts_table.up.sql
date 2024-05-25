create table if not exists posts (
  post_id int generated always as identity,
  owner text not null,
  title text not null,
  body text,
  open_timestamp timestamptz default (timezone('utc', now())) not null,
  price int not null,
  reports int default 0 not null,
  visible bool default false,
  image_paths text,

  primary key(post_id),
  foreign key(owner) references users(email)
);
