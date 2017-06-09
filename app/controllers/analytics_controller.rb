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
    @us_table_js = Hash[us_state_vals.each_with_index.map{|v, i| [v[0], i]}]
    @us_table = us_state_vals.each_with_index.map{|v, i| {unique_name: v, id: i}}

    # Generate Row indexing
    # Creates array with following: [col_sum, matrix_index, product_id]
    # Recall matrix index is sorted by alphabetical so we are trying to rearrange.
    @col_sum_a = sort_sum_col_value(col_names, matrix)


    @row_sum_a = sort_sum_row_value(@us_table, matrix)

    # Js version only needs to keep track of index to sum, matrix pos is in array pos.
    # Contains {col_id => sum}
    @row_sum_a_js = Hash[@row_sum_a.each_with_index.map{|h, ind| [h[1], [h[0].to_i, ind]]}]
    @col_sum_a_js = Hash[@col_sum_a.each_with_index.map{|h, ind| [h[2], [h[0].to_i, ind]]}]

    # Generate a list of columns.
    @list_cols = @col_sum_a.map{|h| h[2].to_i}

    @values = {col_names: col_names, row_names: us_states, query_results: query_results, matrix: matrix}
  end

  # AJAX for refreshing
  def refresh()
    # Contains new matrix values that have been changed.
    list_cols = JSON.parse(params["list_cols"])
    diff = diff_query list_cols
    @diff_values = diff[1]

    # Order only reflects decreasing order, not matrix order.
    @diff_column_sum = diff[0]

    # Create a simple lookup table
    if diff.length == 0
      # No change, just set to list_cols
      @diff_cols = list_cols
    else
      @diff_cols = @diff_column_sum.map{|h| h["product_id"]}
    end
    @diff_column_sum = Hash[@diff_column_sum.map{|h| [h["product_id"], h["total"].to_i]}]

    render :layout=>false
  end

  def diff_query(also_prods)
    con = ActiveRecord::Base.connection

    # Generate top columns
    top_sql =
    "
    SELECT topkek.id AS product_id, topkek.unique_name, topkek.total
    FROM
    (
      SELECT prod.id, prod.unique_name, COALESCE(prod.price * pur.totalQuantity, 0) AS total
      FROM Products prod
      LEFT OUTER JOIN
      (
        SELECT purch.product_id, SUM(purch.quantity) AS totalQuantity
        FROM New_Purchases purch
        GROUP BY purch.product_id
        ORDER BY totalQuantity
      ) AS pur
      ON prod.id = pur.product_id
      ORDER BY total DESC
      LIMIT 50
    ) AS topkek
    ORDER BY topkek.unique_name;
    "

    diff_column_sum = con.execute(top_sql)
    pp diff_column_sum
    # No changes whatsoever.
    if diff_column_sum[0]["total"] == 0
      diff_column_sum = []
    end
    prods = diff_column_sum.map { |e|  e["product_id"]}

    # Get all relevant products
    prods_ids = [*prods, *also_prods].uniq
    prods = prods_ids.join(", ")

    # Get columns product ids associated with products that have changed.
    sql =
    "
    SELECT up.product_unique_name, up.product_id, up.state, COALESCE(SUM(up.price * coal.quantity), 0) as total
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
          WHERE pi.id IN (#{prods})
        ) AS p
    ) AS up
    LEFT OUTER JOIN
    (
      SELECT p.user_id, p.product_id, SUM(p.quantity) AS quantity
      FROM New_Purchases p
      WHERE p.product_id IN (#{prods})
      GROUP BY p.user_id, p.product_id
    ) AS coal
    ON
    up.user_id = coal.user_id AND
    up.product_id = coal.product_id
    GROUP BY up.state, up.product_id, up.product_unique_name
    ORDER BY up.state, up.product_id;"

    return diff_column_sum, con.execute(sql), prods_ids
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
