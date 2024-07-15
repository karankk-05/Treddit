-- Add up migration script here
alter table users add contact_visible bool default false not null;
