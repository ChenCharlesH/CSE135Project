class AnalyticsController < ApplicationController

  def index()
    @col_names = Product.first(10)
  end

end
