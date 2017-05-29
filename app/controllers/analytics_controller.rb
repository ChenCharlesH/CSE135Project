class AnalyticsController < ApplicationController

  def index()
    # Offset?
    @col_names = Product.limit(10).offset(0)
    # Default customers
    @row_names = User.limit(10).offset(0)
  end

  # AJAX for query.
  def query()
    params = params[:filter_options]
    soc = params[:filter_options][:state_or_cust]
    aot = params[:filter_options][:alpha_or_top]
    page = params[:filter_options][:page]
    @query_results = helper_query 0
  end

  # Get the object we need from query.
  def helper_query(off)
    con = ActiveRecord::Base.connection

    prod_q = Product.limit(10).offset(off)
    user_q = User.limit(10).offset(off)

    prod = prod_q.map{|p| p.id}
    user = user_q.map{|u| u.id}

    str =
    "SELECT up.user_unique_name, up.product_unique_name, up.price, coal.quantity
    FROM
    (
    	SELECT u.unique_name as user_unique_name, p.unique_name as product_unique_name,
    				 u.id AS user_id, p.id AS product_id, p.price as price
    	FROM
    		(
          SELECT ui.unique_name, ui.id
          FROM Users ui
          WHERE ui.id IN (#{user.join(", ")})
        ) AS u,
        (
          SELECT pi.unique_name, pi.id, pi.price
          FROM Products pi
          WHERE pi.id IN (#{prod.join(", ")})
        ) AS p
      LIMIT 10
    ) AS up
    FULL OUTER JOIN
    (
    	SELECT purchin.user, purchin.product, SUM(purchin.quantity) AS quantity
    	FROM Purchases purchin
    	GROUP BY purchin.user, purchin.product
    ) AS coal
    ON
    up.user_id = coal.user AND
    up.product_id = coal.product
    ORDER BY up.user_id;"

    con.execute(str)
  end

end
