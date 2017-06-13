<%
Connection con = getconn135();
String getTop10 =
"SELECT v.title, COUNT(likes.video) as cnt
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
PreparedStatement top10pstmt = con.prepareStatement(getTop10);
top10pstmt.setString(1,session.getAttribute("name"));
ResultSet top10 = top10pstmt.executeQuery();
%>
<h3>Welcome <%= session.getAttribute("name") %>, these are the 10 best cat videos for you:</h3>
<table>
  <% while(rs.next()){ %>
    <tr>
      <td><%= rs.getString("title") %></td>
    </tr>
  <%}%>
</table>
<%
con.releaseconn135();
%>
