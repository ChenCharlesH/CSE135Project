class HomeController < ApplicationController
  def index
    @value = Random.rand(1)
  end
end
