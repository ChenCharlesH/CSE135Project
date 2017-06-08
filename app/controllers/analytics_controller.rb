class AnalyticsController < ApplicationController
  before_filter :authorize_owner

  def index()
    # Offset?

    @cat_obj = Category.all
    @cat_options = @cat_obj.map{|h| h.id}

    # Setting the category values.
    if params.has_key?("filter") && params["filter"].has_key?("category_id")
      @cat = cat_param[:category_id].to_i
      if !@cat_options.include?(@cat)
        @cat = -1
      end
    else
      @cat = -1
    end

    col_names = top_prod_query(@cat).to_a

    query_results = helper_query col_names, us_states
    matrix = Array.new
    query_results.each_slice(col_names.length) do |r|
      matrix << r
    end

    @values = {col_names: col_names, row_names: us_states, query_results: query_results, matrix: matrix}
  end

  # Grabs the id and name of the top products
  def top_prod_query(cat)
    con = ActiveRecord::Base.connection

    if cat == -1
      cat = ""
    else
      cat = "WHERE prod.cat = #{cat.to_s}"
    end

    sql = "
      SELECT topkek.id, topkek.unique_name
      FROM
      (
        SELECT prod.id, prod.unique_name, COALESCE(prod.price * pur.totalQuantity, 0) AS total
        FROM Products prod
        LEFT OUTER JOIN
        (
          SELECT purch.product, SUM(purch.quantity) AS totalQuantity
          FROM Purchases purch
          GROUP BY purch.product
          ORDER BY totalQuantity
        ) AS pur
        ON prod.id = pur.product
        #{cat}
        ORDER BY total DESC
        LIMIT 50
      ) AS topkek
      ORDER BY topkek.unique_name;
      "

  return con.execute(sql)

  rescue
      return []
  end

  # AJAX for query.
  def query()
    # TODO: Does not need to check cat because of refresh policy.
    col_names = Product.limit(50).offset(cl_statement)
    # Ran out of things to go through.
    if col_names.length <= 0
      col_page = String(col_page.to_i - 1)
      col_names = Product.limit(50).offset(cl_statement - 10)
      flash[:alert] = "Max columns reached."
    end

    query_results = helper_query col_names, us_states

    @values = {col_names: col_names, row_names: us_states, query_results: query_results, matrix: matrix}
    render :layout=>false
  rescue
    redirect_to "/analytics", flash: {alert: "Query error."}
  end

  # Get the object we need from query.
  def helper_query(prod_q, user_q)
    con = ActiveRecord::Base.connection

    prod = prod_q.map{|p| p["id"]}

    # TODO: Refactor user_q and remove.
    user = user_q.map{|u| "'" + u.first + "'"}

    # SQL INJECTION ON OWN CODE, 1337

    # TODO: Add insert from select statement
    # TODO: Check SUM runtime.
    state_str =
    "SELECT up.state, up.product_unique_name, SUM(up.price * coal.quantity) as total
    FROM
    (
      SELECT u.state as state, p.unique_name as product_unique_name,
             u.id AS user_id, p.id AS product_id, p.price as price
      FROM
        (
          SELECT ui.state, ui.id
          FROM Users ui
        ) AS u,
        (
          SELECT pi.unique_name, pi.id, pi.price
          FROM Products pi
          WHERE pi.id IN (#{prod.join(", ")})
        ) AS p
    ) AS up
    LEFT OUTER JOIN
    (
      SELECT purchin.user, purchin.product, SUM(purchin.quantity) AS quantity
      FROM Purchases purchin
      WHERE purchin.product IN (#{prod.join(", ")})
      GROUP BY purchin.user, purchin.product
    ) AS coal
    ON
    up.user_id = coal.user AND
    up.product_id = coal.product
    GROUP BY up.state, up.product_unique_name
    ORDER BY up.state, up.product_unique_name;"

    return con.execute(state_str)

    rescue
      return []
  end
end

def cat_param
    params.require(:filter).permit("category_id")
end

  # List of state abbreviations
  def us_states
    [
      ['AK'],
      ['AL'],
      ['AR'],
      ['AZ'],
      ['CA'],
      ['CO'],
      ['CT'],
      ['DC'],
      ['DE'],
      ['FL'],
      ['GA'],
      ['HI'],
      ['IA'],
      ['ID'],
      ['IL'],
      ['IN'],
      ['KS'],
      ['KY'],
      ['LA'],
      ['MA'],
      ['MD'],
      ['ME'],
      ['MI'],
      ['MN'],
      ['MO'],
      ['MS'],
      ['MT'],
      ['NC'],
      ['ND'],
      ['NE'],
      ['NH'],
      ['NJ'],
      ['NM'],
      ['NV'],
      ['NY'],
      ['OH'],
      ['OK'],
      ['OR'],
      ['PA'],
      ['RI'],
      ['SC'],
      ['SD'],
      ['TN'],
      ['TX'],
      ['UT'],
      ['VA'],
      ['VT'],
      ['WA'],
      ['WI'],
      ['WV'],
      ['WY']
    ]
  end
