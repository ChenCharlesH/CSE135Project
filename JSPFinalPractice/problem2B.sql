SELECT s.title
FROM suggested s
WHERE s.user IN (
  SELECT u.id
  FROM user u
  WHERE u.name = ?
)
ORDER BY s.likes
LIMIT 10;
