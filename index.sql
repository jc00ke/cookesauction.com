select 'list' as component, "Cooke's Auction Service" as title;

select title, content from sales where datetime(starting_at) > datetime("2023-01-01");
