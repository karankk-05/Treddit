create table if not exists users (
  email text,
  username text not null,
  address text not null,
  profile_pic_path text,
  open_timestamp timestamp default (timezone('utc', now())) not null,
  reports int default 0 not null,
  contact_no varchar(10) not null,

  primary key(email)
);

create table if not exists login(
  email text,
  passwd text not null,

  PRIMARY KEY(email),
  FOREIGN KEY(email) REFERENCES users(email)
);

create table if not exists posts (
  post_id int generated always as identity,
  owner text not null,
  title text not null,
  body text,
  open_timestamp timestamp default (timezone('utc', now())) not null,
  price int not null,
  reports int default 0 not null,
  visible bool default false,
  image_paths text[],

  primary key(post_id),
  foreign key(owner) references users(email)
);
