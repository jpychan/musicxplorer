class FestivalsController < ApplicationController

  respond_to :html, :js, :json

  before_filter :set_form

  def autocomplete
    input = params["query"]
    @results = Festival.autocomplete(input)
    
    @results = @results["airports"].to_json

    respond_to do |format|
      # format.js { render layout: false, content_type: 'text/javascript' }
      format.json { render json: @results }
    end
  end

  def show
    @festival = Festival.find(params[:id])
    render :show
  end

  def search_flights

    @festival = Festival.find(params[:festival_id])
    @first_five_results = @festival.search_flights(params)
       
    respond_to do |format|
      format.js {render layout: false}
    end
  end

  def all
    render :all
  end

  def set_form
    @cabin_classes = [['Economy', 'Economy'], ['Premium Economy', 'PremiumEconomy'], ['Business', 'Business'], ['First Class', 'First']]
    @passenger_numbers = [['0', 0], [ '1', 1], ['2', 2], ['3', 3], ['4', 4], ['5', 5]]
  end

end
