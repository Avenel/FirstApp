# encoding: UTF-8
class BuergschaftController < ApplicationController

  def index
    if current_OZBPerson.canEditB then 
      @buergschaften = Buergschaft.paginate(:page => params[:page], :per_page => 5)
    else
      redirect_to "/"
    end
  end

  def new
    if current_OZBPerson.canEditB then
      @buergschaft = Buergschaft.new
      searchKtoNr()
      searchOZBPerson()
    else
      redirect_to "/"
    end
  end
  
  def searchKtoNr
    if current_OZBPerson.canEditB then
      if( !params[:pnrB].nil? && params[:pnrB].to_i > 0 && !params[:mnrG].nil? && params[:mnrG].to_i > 0) then
        @buergschaft = Buergschaft.find([params[:pnrB], params[:mnrG]] )
      end
      super
    else
      redirect_to "/"
    end
  end
  
  
  def searchOZBPerson
    if current_OZBPerson.canEditB then 
      super
    else
      redirect_to "/"
    end
  end
  
  def edit
    if current_OZBPerson.canEditB then
      searchKtoNr()
    else
      redirect_to "/"
    end
  end
    
  def create 
    if current_OZBPerson.canEditB then
      @buergschaft = Buergschaft.new(params[:buergschaft])
      @errors = @buergschaft.validate!
    
      if !@errors.nil? && @errors.any? then
       searchKtoNr()
       searchOZBPerson()
       render "new"
      else
        @buergschaft.save   
        @buergschaften = Buergschaft.all
        redirect_to :action => "index", :notce => "Bürgschaft erfolgreich angelegt."   
      end
    else
      redirect_to "/"
    end
  end
  
  def update
    if current_OZBPerson.canEditB then
      @buergschaft = Buergschaft.find([params[:pnrB], params[:mnrG]])
      @buergschaft.attributes = params[:buergschaft]
      @errors = @buergschaft.validate!
      
      if !@errors.nil? && @errors.any? then
        searchKtoNr()
        searchOZBPerson()
        render "edit"
      else
        @buergschaft.update_attributes(params[:buergschaft])
        redirect_to :action => "index", :notice => "Bürgschaft erfolgreich aktualisiert."   
      end
    else
      redirect_to "/"
    end
  end
  
  def delete
    if current_OZBPerson.canEditB then
      begin
        @buergschaft = Buergschaft.find([params[:pnrB], params[:mnrG]])
        @buergschaft.delete
      rescue
      end
      
      @buergschaften = Buergschaft.all    
      redirect_to :action => "index"
    else
      redirect_to "/"
    end
  end

end
