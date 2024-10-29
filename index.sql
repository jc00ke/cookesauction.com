SELECT
    'list' AS component,
    "Cooke's Auction Service" AS title;

SELECT
    title,
    content
FROM
    sales
WHERE
    datetime(starting_at) > datetime("2023-01-01");
