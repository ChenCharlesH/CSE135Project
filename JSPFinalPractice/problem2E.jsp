<%
Connection con = getconn135();
String getTop10 =
"SELECT v.id as vidid, v.title as title, COUNT(likes.video) as cnt
FROM video v, (
  SELECT f.followee
  FROM following f
  WHERE f.follower = u.name AND u.name = ?
) as fol
LEFT JOIN likes ON fol.followee = likes.user
WHERE v.id = likes.video
GROUP BY likes.video
ORDER BY cnt DESC
LIMIT 10;";

String isLiked = "
SELECT *
FROM likes l
WHERE l.user IN (
SELECT u.id
FROM user u
WHERE u.name = ?
)
AND l.video = ?;
"
PreparedStatement top10pstmt = con.prepareStatement(getTop10);
top10pstmt.setString(1,session.getAttribute("name"));
ResultSet top10 = top10pstmt.executeQuery();
%>
<h3>Welcome <%= session.getAttribute("name") %>, these are the 10 best cat videos for you:</h3>
<table>
  <% while(rs.next()){ %>
    <tr>
      <td><%= rs.getString("title") %></td>
      <%
      PreparedStatement likedStmt = con.prepareStatement(isLiked)
      likedStmt.setString(1,session.getAttribute("name"));
      likedStmt.setInt(2,rs.getInt("vidid"))
      ResultSet likeSet = likedStmt.executeQuery();
      if (!likeSet.next()){ %>
      <td>LIKE</td>
      <%}%>
    </tr>
  <%}%>
</table>
<%
con.releaseconn135();
%>
