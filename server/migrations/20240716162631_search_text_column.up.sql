begin;
alter table posts add column text_search tsvector generated always as  
(
  case
  when body is null then to_tsvector('english',title)
  else to_tsvector('english',title || ' ' || body)
  end
) stored;
commit;
