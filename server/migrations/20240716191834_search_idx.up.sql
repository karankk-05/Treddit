create index search_idx on posts using GIN(text_search);
