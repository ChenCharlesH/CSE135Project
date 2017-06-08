class AnalyticsController < ApplicationController
  before_filter :authorize_owner

  def index()
    transport_query
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

    # Generate index for US states.
    us_state_vals = us_states
    @us_table = us_state_vals.each_with_index.map{|v, i| {unique_name: v, id: i}}

    # Generate Row indexing
    @col_sum_a = sort_sum_col_value(col_names, matrix)
    @row_sum_a = sort_sum_row_value(@us_table, matrix)

    @values = {col_names: col_names, row_names: us_states, query_results: query_results, matrix: matrix}
  end

  # AJAX for refreshing
  def refresh()
    # Get list of values that have changed.
    new_purch = NewPurchase.all

    if new_purch.length != 0
      prod_col = new_purch.map{|e| e.product_id}.uniq
      prods = prod_col.join(", ")
    else
      return []
    end

    # Get columns product ids associated with products that have changed.
    sql =
    "
    SELECT COALESCE(SUM(p.quantity), 0) AS totalQ
    FROM Purchases p
    WHERE p.product IN (#{prods})
    GROUP BY p.product
    ORDER BY totalQ
    "


  end

  def sort_sum_row_value(values, matrix)
    values_sum_a = Array.new
    matrix.map do |r|
        values_sum = 0
        r.each do |c|
          values_sum += c["total"].to_i
        end
        values_sum_a << values_sum
    end

    values_sum_a = values_sum_a.each_with_index.map{|x, i| [x, i, values[i][:id]]}
    values_sum_a = values_sum_a.sort.reverse
    return values_sum_a
  end

  # Generate the column sums
  def sort_sum_col_value(values, matrix)
    val_sum_a = Array.new
    values.each_with_index do |col, ind|
      val_sum = matrix.map{|e| e[ind]["total"].to_i}.reduce(:+)
      val_sum_a << val_sum
    end

    # append the db id at the end of each val_sum_a
    val_sum_a = val_sum_a.each_with_index.map{|x, i| [x, i, values[i]["id"]]}
    val_sum_a = val_sum_a.sort.reverse
    return val_sum_a
  end

  # Grabs the id and name of the top products
  def top_prod_query(cat)
    con = ActiveRecord::Base.connection

    if cat == -1
      cat = ""
    else
      cat = "WHERE prod.category_id = #{cat.to_s}"
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


# Move our precomputations
def transport_query()
  # Do it all in one trasaction.
  con = ActiveRecord::Base.connection

  # Import precomputation back in.
  sql = '
  START TRANSACTION;
  INSERT INTO public.Purchases ("user",product,quantity,time,created_at,updated_at)
  SELECT np.user_id, np.product_id, np.quantity, np.time, np.created_at, np.updated_at
  FROM New_Purchases AS np;

  TRUNCATE TABLE New_Purchases;

  COMMIT;
  '

    con.execute(sql)
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
