class ApplicationController < ActionController::Base
  protect_from_forgery
  @@i = 13213
   
   # find_by_sql
  def searchKtoNr      
    if params[:ktoNr].nil? then
        @konten = OZBKonto.paginate(:page => params[:page], :per_page => 5) 
    else
      if params[:ktoNr].empty? and params[:mnr].empty? and  params[:name].empty? and 
      params[:ktoEinrDatum].empty? then
        @konten = OZBKonto.paginate(:page => params[:page], :per_page => 5) 
      else
        @konten = OZBKonto;
        
        if( !params[:ktoNr].empty? ) then
          @konten = @konten.where("ktoNr like ?", "%" + params[:ktoNr] + "%")
        end
        
        if( !params[:mnr].empty? ) then
          @konten = @konten.where("mnr like ?", "%" +  params[:mnr] + "%")
        end
        
        if( !params[:name].empty? or !params[:vorname].empty? ) then
          if !params[:name].empty? and params[:vorname].empty? then
            @personen = Person.where( "(name like ? )", "%" + params[:name] + "%" )
          else
            if !params[:vorname].empty? and params[:name].empty? then
              @personen = Person.where( "(vorname like ? )", "%" + params[:vorname] + "%" )
            else
              @personen = Person.where( "(name like ? AND vorname like ?)", "%" + params[:name] + "%", "%" + params[:vorname] + "%" )
            end
          end
          
          puts @personen.inspect
          pnrs = Array.new
          @personen.each do |person|
            pnrs.push(person.pnr)
          end
          @konten = @konten.where("mnr IN (?)", pnrs)

        end
        
        if( !params[:ktoEinrDatum].empty? ) then
          @konten = @konten.where(:ktoEinrDatum => Date.parse(params[:ktoEinrDatum]))
        end
        
        @konten = @konten.paginate(:page => params[:page], :per_page => 5)
      end
    end
  end
  
  def searchOZBPerson
    #Suchkriterien: mnr, pnr, rolle, name, ktoNr
    @personen = Person.paginate(:page => params[:page], :per_page => 5)
    if params[:mnr].nil? then
      @personen = Person.paginate(:page => params[:page], :per_page => 5)
    else
      if params[:mnr].empty? and params[:name].empty? and 
        params[:ktoNr].empty? and params[:rolle].empty? then
          @personen = Person.paginate(:page => params[:page], :per_page => 5) 
      else
        @personen = Person;
        
        if( !params[:mnr].empty? ) then
          @personen = @personen.where( "pnr like ?", "%" +  params[:mnr] + "%" )
        end
                
        if( !params[:name].empty? or !params[:vorname].empty? ) then
          if !params[:name].empty? and params[:vorname].empty? then
            @personen = Person.where( "(name like ? )", "%" + params[:name] + "%" )
          else
            if !params[:vorname].empty? and params[:name].empty? then
              @personen = Person.where( "(vorname like ? )", "%" + params[:vorname] + "%" )
            else
              @personen = Person.where( "(name like ? AND vorname like ?)", "%" + params[:name] + "%", "%" + params[:vorname] + "%" )
            end
          end
        end
        
        if( !params[:rolle].empty? ) then
          @personen = @personen.where(:rolle => params[:rolle])
        end
        
        if( !params[:ktoNr].empty? ) then
          @konten = OZBKonto.where( "ktoNr LIKE ?", "%" + params[:ktoNr] + "%" )
          
          pnrs = Array.new
          @konten.each do |konto|
            pnrs.push(konto.mnr)
          end
          
          @personen = @personen.where( " pnr IN (?)", pnrs )
        end
        
        @personen = @personen.paginate(:page => params[:page], :per_page => 5)
      end
    end
  end
  
end
