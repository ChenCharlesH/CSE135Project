class SimilarController < ApplicationController

  def index()
    @sim_prod = helper_query
  end

  def helper_query()
    con = ActiveRecord::Base.connection

    query_str =
  "WITH setw AS (
  SELECT sales.uid AS uid, sales.pid as pid, sales.total AS total
  FROM
  (
    SELECT up.user_id as uid, up.product_id as pid, (up.price * coal.quantity) as total
    FROM
    (
      SELECT u.unique_name as user_unique_name, p.unique_name as product_unique_name,
             u.id AS user_id, p.id AS product_id, p.price as price
      FROM Users u, Products p
    ) AS up
    LEFT OUTER JOIN
    (
      SELECT purchin.user, purchin.product, SUM(purchin.quantity) AS quantity
      FROM Purchases purchin
      GROUP BY purchin.user, purchin.product
    ) AS coal
    ON
    up.user_id = coal.user AND
    up.product_id = coal.product
  ) AS sales
)
SELECT *
FROM
(
  SELECT summing.pidO, summing.pidT, (summing.num / (SQRT(summing.denom1) * SQRT(summing.denom2))) as cosine
  FROM
  (
    SELECT rows.pidO, rows.pidT,
           CAST(SUM(rows.mult) AS float) AS num,
           CAST(SUM(rows.prodOMult) AS float) AS denom1,
           CAST(SUM(rows.prodTMult) AS float) AS denom2
    FROM
    (
      SELECT prodO.pid AS pidO, prodT.pid AS pidT,
             (prodO.total * prodO.total) AS prodOMult,
             (prodT.total * prodT.total) AS prodTMult,
             (prodO.total * prodT.total) AS mult
      FROM setw AS prodO
      LEFT OUTER JOIN setw AS prodT
      ON prodO.uid = prodT.uid
    ) AS rows
    GROUP BY rows.pidO, rows.pidT
  ) as summing
) as ordered
ORDER BY cosine;"

    con.execute(query_str)

  rescue
    return []
  end
end
