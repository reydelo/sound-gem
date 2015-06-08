class StreamsController < ApplicationController

  def random

  end

  def popular
    current_user.popular.each do |track|
    @tracks = track.page(params[:page]).per(10)
    respond_to do |format|
      format.html
      format.js
    end
  end
  end

  def recent
  end

end
