class ApplicationController < ActionController::Base
  protect_from_forgery
  @@i = 13213
   
  def test
    @person = Person.find(1)
  end
  
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
          @konten = @konten.where(:ktoEinrDatum => params[:ktoEinrDatum])
        end
        
        @konten = @konten.paginate(:page => params[:page], :per_page => 5)
      end
    end
  end
  
  def searchOZBPerson
  
  end
  
end
