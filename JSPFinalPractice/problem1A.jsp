<%
// Check is logged in if necessary.

Connection con = getconn135();
String getTop10 =
"SELECT v.title AS title, COUNT(likes.video) as cnt
FROM video v, (
  SELECT f.followee
  FROM following f
  WHERE f.follower = u.id AND u.id = ?
) as fol
LEFT JOIN likes ON fol.followee = likes.user
WHERE v.id = likes.video
GROUP BY likes.video
ORDER BY cnt DESC
LIMIT 10;";
PreparedStatement top10pstmt = con.prepareStatement(getTop10);

// Get the name of the user .
String getName =
"SELECT u.name
FROM User u
WHERE u.id  = ?
LIMIT 1;";
PreparedStatement namae = con.preparestatement(getName);
namae.setInt(1, (int) session.getAttribute("user"));
ResultSet watashinonamaewa = namae.executeQuery();

top10pstmt.setInt(1,session.getAttribute("user"));
ResultSet top10 = top10pstmt.executeQuery();
%>
<% watashinonamaewa.first();%>
<h3>Welcome <%= watashinonamaewa.getString(1) %>, these are the 10 best cat videos for you:</h3>
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
