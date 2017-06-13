INSERT INTO suggested [(user,video,title,likes)]
  SELECT u.id, v.id, v.title, COUNT(l.video)
  FROM video v, likes l, user u
  [WHERE u.id = l.user];
