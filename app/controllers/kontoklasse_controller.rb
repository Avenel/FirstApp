class KontoklasseController < ApplicationController

	before_filter :authenticate_OZBPerson!

  def index
    @kontoklassen = Kontenklasse.all
  end
  
  def edit
    @kontoklasse = Kontenklasse.find(params[:id])
  end
  
  def save
    @kontoklasse = Kontenklasse.find(params[:oldKKL])
    
    @new_kontoklasse = Kontenklasse.create( :kkl => params[:kkl], :prozent => params[:prozent],
                                            :kklAbDatum => Date.new )
    @new_kontoklasse.save
    @kontoklasse.delete
  
    @kontoklasse = Kontenklasse.find(params[:kkl])
    
    puts params
    
    render :edit
  end

end
