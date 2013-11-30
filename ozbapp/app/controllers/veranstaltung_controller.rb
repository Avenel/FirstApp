#!/bin/env ruby
# encoding: utf-8
class VeranstaltungController < ApplicationController
#  protect_from_forgery
  before_filter :authenticate_user!
  load_and_authorize_resource :only => [:createDeleteTeilnahme, :createVeranstaltung, :editVeranstaltungen, :newVeranstaltung]
  
  
  def listTeilnahmen
    @OZBPerson  = OZBPerson.find(params[:Mnr])
    @Person     = Person.get(@OZBPerson.Mnr)
    
    
    @Teilnahmen = Teilnahme.find(:all, :conditions =>{:Pnr => @OZBPerson.Mnr})
    @Veranstaltungen ||= Array.new
    @Teilnahmen.each do |t|
      veranstaltung = Veranstaltung.find(t.Vnr)
      veranstaltungsart = Veranstaltungsart.find(veranstaltung.VANr)
  
      case t.TeilnArt
      when "l"
        teilnahmeArtAusgeschrieben = "eingeladen"
      when "e"
        teilnahmeArtAusgeschrieben = "entschuldigt"
      when "a"
        teilnahmeArtAusgeschrieben = "anwesend"
      when "u"
        teilnahmeArtAusgeschrieben = "unentschuldigt"
      end
      @Veranstaltungen << [veranstaltung, t, veranstaltungsart, teilnahmeArtAusgeschrieben]
      
    end 
  end
  
  
  def createDeleteTeilnahme      
    if (params[:delete] == "true") then
      
      @Teilnahme = Teilnahme.find(:first, :conditions =>{:Vnr => params[:vnr1], :Pnr => params[:pnr1], :TeilnArt => params[:teilnArt2]})
      if !@Teilnahme.nil? then
        @Teilnahme.delete
        
        flash[:notice] = "Teilnahme wurde gelöscht."
        session[:return_to] = request.referer
        redirect_to session[:return_to]
      else
        flash[:error] = "Teilnahme konnte nicht gelöscht werden."
        session[:return_to] = request.referer
        redirect_to session[:return_to]
      end
  
    else
    
      @errors = Array.new 
      begin    
        #Beginne Transaktion
        ActiveRecord::Base.transaction do
          
          @Teilnahme = Teilnahme.find(:first, :conditions => {:Pnr => params[:pnr], :Vnr => params[:vnr]})
          @Teilnahme2 = Teilnahme.find(:first, :conditions => {:Pnr => params[:pnr1], :Vnr => params[:vnr1]})
          
          if !@Teilnahme.nil? then
            @update = true
            @Teilnahme.update_attribute(:TeilnArt, params[:teilnArt])
            @Teilnahme.update_attribute(:SachPnr, current_user.Mnr)
            
          elsif !@Teilnahme2.nil? then
            @update = true
            @Teilnahme2.update_attribute(:TeilnArt, params[:teilnArt2])
            @Teilnahme2.update_attribute(:SachPnr, current_user.Mnr)
            
          else
            # Veranstaltung erstellen und validieren
            @new_Teilnahme = Teilnahme.new(:Pnr => params[:pnr], :Vnr => params[:vnr], :TeilnArt => params[:teilnArt], :SachPnr => current_user.Mnr)
            
            #Fehler aufgetreten?
            if !@new_Teilnahme.valid? then
              @errors.push(@new_Teilnahme.errors)
            end
            @update = false
            
            @new_Teilnahme.save!
          end
          @update == false ? flash[:success] = "Teilnahme wurde erfolgreich hinzugefügt." : flash[:success] = "Teilnahme wurde erfolgreich aktualisiert."
          
          session[:return_to] = request.referer
          redirect_to session[:return_to]
        end
      rescue
        flash[:error] = "Teilnahme konnte nicht hinzugefügt werden."
        session[:return_to] = request.referer
        redirect_to session[:return_to]
      end
    end
  end
  
  
  def listVeranstaltung
    @DistinctPersonen = Person.find(:all, :select => "DISTINCT Pnr, Name, Vorname")
    @TeilnahmeArten = ['u','e','l','a']
    @new_Teilnahme = Teilnahme.new
    
    #["Gesellschafter",l,a,e,u,G(Gesamt)],M,P,S -> Erste Ausgeschrieben, zweite sind die eingeladenen Gesellschafter , letzte Gesamt
    @AnzahlRollen = [["Gesellschafter",0,0,0,0,0],["Mitglieder",0,0,0,0,0],["Partner",0,0,0,0,0],["Studenten",0,0,0,0,0]]
    @AnzahlGesamt = [0,0,0,0] #G,M,P,S
    
    @vnr = request.fullpath.split('/')[3]
    
    if @update.nil? then
      @update = false
    else
      @update = true
    end
    
    
    @veranstaltung = Veranstaltung.find(@vnr)
    @veranstaltungsart = Veranstaltungsart.find(@veranstaltung.VANr)
    @Teilnahmen = Teilnahme.find(:all, :conditions => {:Vnr => @veranstaltung.Vnr})
    @Teilnahmen.sort! { |a,b| a.Pnr <=> b.Pnr }
    @TeilnUndPerson = Array.new
    
    @Teilnahmen.each do |teilnahme|
      case teilnahme.TeilnArt
      when "l"
        teilnahmeArtAusgeschrieben = "eingeladen"
      when "e"
        teilnahmeArtAusgeschrieben = "entschuldigt"
      when "a"
        teilnahmeArtAusgeschrieben = "anwesend"
      when "u"
        teilnahmeArtAusgeschrieben = "unentschuldigt"
      end
      person = Person.get(teilnahme.Pnr)
      @TeilnUndPerson << [teilnahme, person, teilnahmeArtAusgeschrieben]
      case person.Rolle
        when "G"
          @AnzahlRollen[0][5] += 1
          case teilnahme.TeilnArt
            when "l"
              @AnzahlRollen[0][1] += 1
            when "a"
              @AnzahlRollen[0][2] += 1
            when "e"
              @AnzahlRollen[0][3] += 1
            when "u"
              @AnzahlRollen[0][4] += 1          
          end
        when "M"
          @AnzahlRollen[1][5] += 1
          case teilnahme.TeilnArt
            when "l"
              @AnzahlRollen[1][1] += 1
            when "a"
              @AnzahlRollen[1][2] += 1
            when "e"
              @AnzahlRollen[1][3] += 1
            when "u"
              @AnzahlRollen[1][4] += 1          
          end
        when "P"
          @AnzahlRollen[2][5] += 1
          case teilnahme.TeilnArt
            when "l"
              @AnzahlRollen[2][1] += 1
            when "a"
              @AnzahlRollen[2][2] += 1
            when "e"
              @AnzahlRollen[2][3] += 1
            when "u"
              @AnzahlRollen[2][4] += 1          
          end
        when "S"
          @AnzahlRollen[3][5] += 1
          case teilnahme.TeilnArt
            when "l"
              @AnzahlRollen[3][1] += 1
            when "a"
              @AnzahlRollen[3][2] += 1
            when "e"
              @AnzahlRollen[3][3] += 1
            when "u"
              @AnzahlRollen[3][4] += 1          
          end
      end 
    end
  end
  
  
  def createVeranstaltung
    @errors = Array.new                                       
    begin    
      #Beginne Transaktion
      ActiveRecord::Base.transaction do
        
        # Veranstaltung erstellen und validieren
        @new_Veranstaltung = Veranstaltung.new(:Vnr => Veranstaltung.last.Vnr + 1, :VANr => params[:VANr], :VADatum => params[:vadatum], :VAOrt =>params[:vaort], :SachPnr => current_user.Mnr)
        
        #Fehler aufgetreten?
        if !@new_Veranstaltung.valid? then
          @errors.push(@new_Veranstaltung.errors)
        end
        
        #neu
        
        @EinzuladendeMitglieder = Array.new
        
        if params[:VANr] == '2' then
          @EinzuladendeMitglieder = OZBPerson.find(:all, :conditions => {:Schulungsdatum => nil, :Austrittsdatum => nil})
        end
        
        if params[:VANr] == '1' then
          @OZBPersonen = Array.new
          @OZBPersonen = OZBPerson.find(:all, :conditions => {:Austrittsdatum => nil})
          @OZBPersonen.each do |person|
            @Person = Person.find(:first, :conditions => ['Pnr = ? AND GueltigBis > ?', person.Mnr, DateTime.now])
            case @Person.Rolle
            when "M"
                @EinzuladendeMitglieder << OZBPerson.find(@Person.Pnr)
            when "G"
                @EinzuladendeMitglieder << OZBPerson.find(@Person.Pnr)
            when "P"
                @EinzuladendeMitglieder << OZBPerson.find(@Person.Pnr)
            end
          end
        end          

        @new_Veranstaltung.save!
        
        if !@EinzuladendeMitglieder.blank? then
          @teilnArt = 'l'
          
          @EinzuladendeMitglieder.each do |mitglied|
            begin
              ActiveRecord::Base.transaction  do
                @new_Teilnahme = Teilnahme.new(:Vnr => @new_Veranstaltung.Vnr, :Pnr => mitglied.Mnr,  :TeilnArt => @teilnArt, :SachPnr => current_user.Mnr)
                @new_Teilnahme.save
              end
            rescue
            end
          end
        end
        

        flash[:success] = "Veranstaltung wurde erfolgreich hinzugefügt."
        redirect_to "/Verwaltung/Veranstaltungen"
      end
    rescue
      flash[:error] = "Veranstaltung konnte nicht hinzugefügt werden."
      session[:return_to] = request.referer
      redirect_to session[:return_to]
    end
  end
  
  
  
  @@Veranstaltungen2 = Hash["Bitte auswählen", "", "Gesellschaftsversammlung", "1", "Schulung", "2", "Vortrag", "3", "Seminar", "4"]  
  #Workaround - Da Ruby 1.8.7 die key()-Funktion nicht kennt
  @@Veranstaltungen = Hash["", "Nicht angegeben", "1", "Gesellschaftsversammlung","2","Schulung","3","Vortrag","4","Seminar"]
  
  def editVeranstaltungen
    @Veranstaltungen = @@Veranstaltungen2.sort
    @VeranstaltungsName = @@Veranstaltungen
    @Veranstaltung = Veranstaltung.paginate(:page => params[:page], :per_page => 25)
    @Veranstaltungsarten = Veranstaltungsart.find(:all)
    @new_Veranstaltung = Veranstaltung.new
    @VeranstaltungenUndArt = Array.new
    @edit = false
    
    @Veranstaltung.each do |v|
      veranstaltungsart = Veranstaltungsart.find(v.VANr)
      @VeranstaltungenUndArt << [v,veranstaltungsart]  
    end
  end
  
  
  def newVeranstaltung      
    @Veranstaltungen = @@Veranstaltungen2.sort
    @VeranstaltungsName = @@Veranstaltungen
    @Veranstaltung = Veranstaltung.paginate(:page => params[:page], :per_page => 25)
    @Veranstaltungsarten = Veranstaltungsart.find(:all)
    @new_Veranstaltung = Veranstaltung.new
    @new_Teilnahme = Teilnahme.new
    @VeranstaltungenUndArt = Array.new

    @Veranstaltung.each do |v|
      veranstaltungsart = Veranstaltungsart.find(v.VANr)
      @VeranstaltungenUndArt << [v,veranstaltungsart]  
    end
  end
  
  
  
  def deleteTeilnahme
    @Teilnahme = Teilnahme.find(:first, :conditions =>{:Vnr => params[:vnr2], :Pnr => params[:pnr2], :TeilnArt => params[:teilnArt3]})
    if !@Teilnahme.nil? then
      @Teilnahme.destroy
      
      flash[:notice] = "Teilnahme wurde gelöscht."
      session[:return_to] = request.referer
      redirect_to session[:return_to]
    else
      flash[:error] = "Teilnahme konnte nicht gelöscht werden."
      session[:return_to] = request.referer
      redirect_to session[:return_to]
    end
  end

end
