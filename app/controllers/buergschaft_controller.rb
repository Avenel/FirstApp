class BuergschaftController < ApplicationController

  def index
    @buergschaften = Buergschaft.paginate(:page => params[:page], :per_page => 5)
  end

  def new
    searchKtoNr()
    searchOZBPerson()
  end
  
  def searchKtoNr
    if( !params[:pnrB].nil? ) then
      @buergschaft = Buergschaft.find([params[:pnrB], params[:mnrG]] )
    end
    super
  end
  
  
  def searchOZBPerson
    super
  end
  
  def edit
    searchKtoNr()
  end
    
  def save
    begin
      @buergschaft = Buergschaft.find([params[:pnrB], params[:mnrG]])
      @buergschaft.sichEndDatum = Date.parse(params[:sichEndDatum])
      @buergschaft.sichBetrag = params[:sichBetrag]
      @buergschaft.sichKurzBez = params[:sichKurzBez]
      @buergschaft.ktoNr = params[:ktoNr]
      @buergschaft.save
      puts @buergschaft.inspect
    rescue
        @new_buergschaft = Buergschaft.create( :pnrB => params[:pnrB], :mnrG => params[:mnrG],
                                              :ktoNr => params[:ktoNr], :sichAbDatum => Date.parse(params[:sichAbDatum]),
                                              :sichEndDatum => Date.parse(params[:sichEndDatum]), :sichBetrag => params[:sichBetrag],
                                              :sichKurzBez => params[:sichKurzBez] )
        @new_buergschaft.save
    end
    
    @buergschaften = Buergschaft.all
    redirect_to :action => "index"
  end
  
  def delete
    begin
      @buergschaft = Buergschaft.find([params[:pnrB], params[:mnrG]])
      @buergschaft.delete
    rescue
    end
    
    @buergschaften = Buergschaft.all    
    redirect_to :action => "index"
  end

end