
SELECT u.id as id,
       u.name as name,
       COUNT(DISTINCT lu.id) AS language_count, 
       COUNT(DISTINCT r.id) AS repository_count,
       u.stars as stars
FROM users u
LEFT JOIN language_users lu ON u.id = lu.user_id
LEFT JOIN repositories r ON u.id = r.user_id
GROUP BY u.id;
