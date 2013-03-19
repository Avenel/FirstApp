# encoding: UTF-8
class KontenklasseController < ApplicationController

	before_filter :authenticate_OZBPerson!

  def index
    if current_OZBPerson.canEditD then
      @kontenklassen = Kontenklasse.paginate(:page => params[:page], :per_page => 5)
    else
      redirect_to "/"
    end
  end
  
  def new
    if current_OZBPerson.canEditD then
      @kontenklasse = Kontenklasse.new
    else
      redirect_to "/"
    end
  end
  
  def edit
    if current_OZBPerson.canEditD then
      @kontenklasse = Kontenklasse.find(params[:id])
    else
      redirect_to "/"
    end
  end
  
  def create
    if current_OZBPerson.canEditD then
      @kontenklasse = Kontenklasse.new(params[:kontenklasse])
      @errors = @kontenklasse.validate!
      
      if !@errors.nil? && @errors.any? then
       render "new"
      else
        @kontenklasse.save   
        @kontenklassen = Kontenklasse.all
        redirect_to :action => "index", :notice => "Kontenklasse erfolgreich angelegt."   
      end
      
    else
      redirect_to "/"
    end
  end  
  
  def update
    if current_OZBPerson.canEditD then
      @kontenklasse = Kontenklasse.find(params[:id])
      @kontenklasse.attributes = params[:kontenklasse]
      @errors = @kontenklasse.validate!
      
      if !@errors.nil? && @errors.any? then
        puts @errors.inspect
        render "edit"
      else
        @kontenklasse.update_attributes(params[:kontenklasse])
        @kontenklassen = Kontenklasse.all
        redirect_to :action => "index", :notice => "Kontoklasse erfolgreich aktualisiert."   
      end
      
    else
      redirect_to "/"
    end
  end
  
  def delete
    if current_OZBPerson.canEditD then
      begin
        @kontenklasse = Kontenklasse.find(params[:id])
        @kontenklasse.delete
      rescue
      end
      
      @kontenklassen = Kontenklasse.all    
      redirect_to :action => "index"
    else
      redirect_to "/"
    end
  end
  
end
