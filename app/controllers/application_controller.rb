class ApplicationController < ActionController::Base
  protect_from_forgery
  @@i = 13213
   
   
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
          @konten = @konten.where(:ktoNr => params[:ktoNr])
        end
        
        if( !params[:mnr].empty? ) then
          @konten = @konten.where(:mnr => params[:mnr])
        end
        
        if( !params[:name].empty? ) then
          @personen = Person.all
          
          @personen.each do |person|
            name = person.name.to_s.downcase + " " +  person.vorname.to_s.downcase
            searchName = params[:name].downcase
            puts name
            if name.include? searchName then
              @konten = @konten.where(:mnr => person.OZBPerson.first.mnr)
              break
            end
            
          end
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
      if params[:mnr].empty? and params[:pnr].empty? and  params[:name].empty? and 
        params[:ktoNr].empty? and params[:rolle].empty? then
          @personen = Person.paginate(:page => params[:page], :per_page => 5) 
      else
        @personen = Person;
        
        if( !params[:mnr].empty? ) then
          @personen = @personen.where( :pnr => OZBPerson.where(:mnr => params[:mnr]).first.ueberPnr )
        end
        
        if( !params[:pnr].empty? ) then
          @personen = @personen.where(:pnr => params[:pnr])
        end
        
        if( !params[:name].empty? ) then
          @theOthers = Person.all
          @theOne = nil
          @theOthers.each do |person|
            name = person.name.to_s.downcase + " " +  person.vorname.to_s.downcase
            searchName = params[:name].downcase
            if name.include? searchName then
              @theOne = person
              break
            end
          end

          if( !@theOne.nil? ) then
            @personen = @personen.where( :pnr => @theOne.pnr ) 
          else
            @personen = @personen.where( :pnr => -1 ) 
          end
          
        end
        
        if( !params[:rolle].empty? ) then
          @personen = @personen.where(:rolle => params[:rolle])
        end
        
        if( !params[:ktoNr].empty? ) then
          @personen = @personen.where( :pnr => OZBPerson.where( :mnr => OZBKonto.where( :ktoNr => params[:ktoNr] ).first.mnr ).first.ueberPnr )
        end
        
        @personen = @personen.paginate(:page => params[:page], :per_page => 5)
      end
    end
  end
  
end
