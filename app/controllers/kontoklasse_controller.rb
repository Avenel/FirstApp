class KontoklasseController < ApplicationController

	before_filter :authenticate_OZBPerson!

  def index
    @kontoklassen = Kontenklasse.all
  end
  
  def new
  end
  
  def edit
    @kontoklasse = Kontenklasse.find(params[:id])
  end
  
  def save
    begin
      @kontoklasse = Kontenklasse.find(params[:kkl])
      @kontoklasse.prozent = params[:prozent]
      @kontoklasse.save!
    rescue
        @new_kontoklasse = Kontenklasse.create( :kkl => params[:kkl], :prozent => params[:prozent],
                                              :kklAbDatum => Date.new )
        @new_kontoklasse.save!
    end
    
    @kontoklassen = Kontenklasse.all
    redirect_to :action => "index"
  end
  
  def delete
    begin
      @kontoklasse = Kontenklasse.find(params[:id])
      @kontoklasse.delete
    rescue
    end
    
    @kontoklassen = Kontenklasse.all    
    redirect_to :action => "index"
  end

end
