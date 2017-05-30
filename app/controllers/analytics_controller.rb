class AnalyticsController < ApplicationController
  def index()
    # Offset?
    col_names = Product.select(:id, :unique_name).limit(10).offset(0)
    # Default customers
    row_names = User.select(:id, :unique_name).limit(20).offset(0)
    # Set default values
    state_or_cust = "customer"
    alpha_or_top = "alpha"
    col_page = 0
    row_page = 0
    query_results = helper_query col_names, row_names
    @values = {state_or_cust: state_or_cust, alpha_or_top: alpha_or_top, row_page: row_page, col_page: col_page, col_names: col_names, row_names:row_names, query_results: query_results}
  end

  # AJAX for query.
  def query()
    params = filter_params
    state_or_cust = params[:state_or_cust]
    alpha_or_top = params[:alpha_or_top]

    row_page = params[:row_page]
    rp_statement = row_page.to_i * 20
    col_page = params[:col_page]
    cl_statement = col_page.to_i * 10

    #TODO: Double check basecase
    col_names = Product.limit(10).offset(cl_statement)

    if state_or_cust == "customer"
      row_names = User.limit(20).offset(rp_statement)
    else
      # TODO: Allow user name updating.
      row_names = User.limit(20).offset(rp_statement)
    end

    query_results = helper_query col_names, row_names

    @values = {state_or_cust: state_or_cust, alpha_or_top: alpha_or_top, row_page: row_page, col_page: col_page, col_names: col_names, row_names:row_names, query_results: query_results}
    render :layout=>false
  end

  # Get the object we need from query.
  def helper_query(prod_q, user_q)
    con = ActiveRecord::Base.connection

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
      LIMIT 200
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
    ORDER BY up.user_id, up.product_id;"

    con.execute(str)
  rescue
    return []
  end

  # Strong parameters
  def filter_params
    params_res = params.required(:filter_options).permit(:alpha_or_top, :state_or_cust)
    params_res[:row_page] = params[:row_page]
    params_res[:col_page] = params[:col_page]
    return params_res
  rescue
    params.permit(:row_page, :col_page, :alpha_or_top, :state_or_cust)
  end
end

  # List of state abbreviations
@@states =  [
    'AL',
    'AK',
    'AZ',
    'AR',
    'CA',
    'CO',
    'CT',
    'DE',
    'DC',
    'FL',
    'GA',
    'HI',
    'ID',
    'IL',
    'IN',
    'IA',
    'KS',
    'KY',
    'LA',
    'ME',
    'MD',
    'MA',
    'MI',
    'MN',
    'MS',
    'MO',
    'MT',
    'NE',
    'NV',
    'NH',
    'NJ',
    'NM',
    'NY',
    'NC',
    'ND',
    'OH',
    'OK',
    'OR',
    'PA',
    'PR',
    'RI',
    'SC',
    'SD',
    'TN',
    'TX',
    'UT',
    'VT',
    'VA',
    'WA',
    'WV',
    'WI',
    'WY'
  ]
