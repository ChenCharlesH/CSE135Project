class HomeController < ApplicationController
  def index
    @value = Random.rand(3)
  end
end
