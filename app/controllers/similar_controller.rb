class SimilarController < ApplicationController

  def index()
    sim_prod = helper_query
  end

  def helper_query()
    con = ActiveRecord::Base.connection

    query_str = ""

    con.execute(query_str)

  rescue
    return []
  end
end
