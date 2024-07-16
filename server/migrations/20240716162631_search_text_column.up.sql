begin;
alter table posts add column text_search tsvector generated always as  
(
  setweight(to_tsvector('english',title),'A') || setweight(to_tsvector('english',coalesce(body,'')),'B')
) 
stored;
commit;
