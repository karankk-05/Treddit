create table if not exists post_chats (
  chat_id int generated always as identity,
  post_id int not null,
  chat_timestamp timestamptz default (timezone('utc', now())) not null,
  sender text not null,
  reciever text not null,
  message text not null,

  primary key(chat_id),
  foreign key(post_id) references posts(post_id),
  foreign key(sender) references users(email),
  foreign key(reciever) references users(email)
);
