class HomeController < ApplicationController
  def index
    @value = Random.rand(2)
  end
end
