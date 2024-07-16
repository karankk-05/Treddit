begin;
alter table posts add column text_search tsvector generated always as  
(to_tsvector('english',title || ' ' || body)) stored;
commit;
