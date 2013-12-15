#!/bin/env ruby
# encoding: utf-8
class SonderberechtigungController < ApplicationController
#  protect_from_forgery
  before_filter :authenticate_user!
  load_and_authorize_resource :only => [:createBerechtigungRollen, :deleteBerechtigungRollen, :editRollen, :editBerechtigungenRollen, :createSonderberechtigung]
  
  @@Rollen2 = Hash["Mitglied", "M", "Fördermitglied", "F", "Partner", "P", "Gesellschafter", "G", "Student", "S"]  
  #Workaround - Da Ruby 1.8.7 die key()-Funktion nicht kennt
  @@Rollen = Hash["M", "Mitglied", "F", "Fördermitglied", "P", "Partner", "G", "Gesellschafter", "S", "Student"]
  
  
  @@Berechtigungen2 = Hash[" Bitte auswählen", "", "Administrator", "IT", "Mitgliederverwaltung", "MV", "Finanzenverwaltung", "RW", "Projekteverwaltung", "ZE", "Öffentlichkeitsverwaltung", "OeA"]  
  #Workaround - Da Ruby 1.8.7 die key()-Funktion nicht kennt
  @@Berechtigungen = Hash["", "Nicht angegeben", "IT", "Administrator", "MV", "Mitgliederverwaltung", "RW", "Finanzenverwaltung", "ZE", "Projekteverwaltung", "OeA", "Öffentlichkeitsverwaltung"]
 
  
  def listGeschaeftsprozesse
    @Geschaeftsprozesse = Geschaeftsprozess.find(:all)
  end
  

  def createBerechtigungRollen      
    @errors = Array.new                                       
    begin    
      #Beginne Transaktion
      ActiveRecord::Base.transaction do
  
        @OZBPerson = OZBPerson.find(params[:mnr])
        @Person = Person.get(@OZBPerson.Mnr)

        
        # Keine Berechtigung dieser Art gefunden
        if    !Sonderberechtigung.find(:first, :conditions => {:Mnr =>params[:mnr], :Berechtigung => params[:berechtigung]}) &&
              !Sonderberechtigung.find(:first, :conditions => {:Mnr =>params[:mnr], :Berechtigung => 'IT'}) &&
              ( !params[:email].blank? || !@Person.EMail.blank? ) then
          @bereitsVorhanden = false


          # Berechtigung erstellen und validieren
           
          if params[:email].blank? && !@Person.EMail.blank? then
            @new_Sonderberechtigung = Sonderberechtigung.new(:Mnr =>params[:mnr], :EMail => @Person.EMail, :Berechtigung => params[:berechtigung])
          else
            @new_Sonderberechtigung = Sonderberechtigung.new(:Mnr =>params[:mnr], :EMail => params[:email], :Berechtigung => params[:berechtigung])
          end
          
          #Fehler aufgetreten?
          if !@new_Sonderberechtigung.valid? then
            @errors.push(@new_Sonderberechtigung.errors)
          end
          
          if params[:berechtigung] == 'IT' then
            @alle_Sonderberechtigungen = Sonderberechtigung.find(:all, :conditions => {:Mnr => params[:mnr]})
            
            @alle_Sonderberechtigungen.each do |sb|
              sb.delete
            end
          end
          
                    
          # Weiterleitung bei erfolgreicher Speicherung  
          flash[:success] = "Berechtigung "+params[:berechtigung]+" wurde "+@Person.Vorname+", "+@Person.Name+" erfolgreich verliehen."
          redirect_to "/Verwaltung/Rollen"
          # Eine solche Berechtigung ist gefunden worden
        else
          if (!params[:email].blank? || !@Person.EMail.blank?) then
            @bereitsVorhanden = true
          else
            @bereitsVorhanden = false
          end
        end
        @new_Sonderberechtigung.save!
      end
    # Bei Fehlern Daten retten
    rescue
      @Berechtigungen = @@Berechtigungen2.sort
      @bereitsVorhanden == false ? flash[:error] = "Berechtigung konnte nicht hinzugefügt werden." : flash[:notice] = "Berechtigung bereits vorhanden."
      session[:return_to] = request.referer
      redirect_to session[:return_to]
    end        
  end


  def deleteBerechtigungRollen      
    @Sonderberechtigung = Sonderberechtigung.find(params[:id])
    @Sonderberechtigung.delete
    
    flash[:success] = "Berechtigung wurde erfolgreich gelöscht."
    #session[:return_to] = request.referer
    redirect_to "/Verwaltung/Rollen"
  end
 
  
  
  def editRollen  
    @falseTrue =["Nein", "Ja"]
    @Berechtigung =["IT", "RW", "MV", "ZE", "OeA"]
    @Rollen = @@Rollen
  
    @Berechtigungen = @@Berechtigungen2.sort
    @BerechtigungsName = @@Berechtigungen
    
    @OZBPersonen ||= Array.new
    @Sonderberechtigungen = Sonderberechtigung.find(:all)
    
      @Sonderberechtigungen.each do |sonderberechtigung|
        @OZBPerson = OZBPerson.find(sonderberechtigung.Mnr)
        unless @OZBPersonen.include?(@OZBPerson)
          @OZBPersonen << @OZBPerson
        end
      end
    @OZBPersonen.sort! { |a,b| a.Mnr <=> b.Mnr }
      
    @new_Sonderberechtigung = Sonderberechtigung.new
  end
  
  
 ### Mitglieder Administrationsrechte geben ###
  def editBerechtigungenRollen      
      #@OZBPerson = OZBPerson.find(params[:Mnr])
     # @Person = Person.get(@OZBPerson.Mnr)
      
      @Berechtigungen = @@Berechtigungen2.sort
      @BerechtigungsName = @@Berechtigungen
      

      @new_Sonderberechtigung = Sonderberechtigung.new
  end
  
  
  def createSonderberechtigung   
    @nil = nil
    @AktiveOzbPersonen = OZBPerson.find(:all, :conditions => {:Austrittsdatum => @nil})
    @DistinctPersonen ||= Array.new
    logger.debug @DistinctPersonen.empty?
    @AktiveOzbPersonen.each do |ozbperson|
      @Person = Person.get(ozbperson.Mnr)
      unless @DistinctPersonen.include?(@Person)
        @DistinctPersonen << @Person
      end
    end
    
  
    @mnr = nil
    @Berechtigungen = @@Berechtigungen2.sort
    @BerechtigungsName = @@Berechtigungen
      
    @new_Sonderberechtigung = Sonderberechtigung.new
  end
  

  
end
