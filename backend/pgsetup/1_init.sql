create table if not exists users (
  email varchar(50),
  username varchar(255) not null,
  address varchar(255) not null,
  profile_pic_path varchar(100),
  open_timestamp timestamp default (timezone('utc', now())) not null,
  reports int default 0 not null,
  contact_no char(10) not null,

  primary key(email)
);

create table if not exists login(
  email varchar(50),
  passwd bytea not null,

  FOREIGN KEY(email) REFERENCES users(email)
);

create table if not exists posts (
  post_id int generated always as identity,
  owner varchar(50) not null,
  title varchar(255) not null,
  body text,
  open_timestamp timestamp default (timezone('utc', now())) not null,
  price int not null,
  reports int default 0 not null,
  image_paths text[],

  primary key(post_id),
  foreign key(owner) references users(email)
);
