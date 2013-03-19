class Punkteberechnung

  def self.calc_score(date_begin, date_end, money_begin, kontonummer)
    t  = Array.new
    # morgiges Datum
    t << date_begin.tomorrow 
    tt = Array.new
    # liefert Anzahl der Tage des Monat im aktuellen Jahr
    tt << Time::days_in_month(date_begin.month, date_begin.year)
    # Konvertierung des Start- und Enddatums in Sekunden
    b  = date_begin.to_time.to_i
    e  = date_end.to_time.to_i
    # Differenz der Tage bis zum Ende des Monats in Sekunden
    d  = b + ((tt[0] - date_begin.day) * 86400)
    
    # Berechnet für die verbleibenden Tage in den Monaten, die Differenzen und die Anzahl der Tage im Monat
    while d <= e do
      t << Time.at(d).strftime("%Y-%m-%d").to_date
      b = d + 86400 # +1 Tag
      t << Time.at(b).strftime("%Y-%m-%d").to_date
      d = b + (Time::days_in_month(Time.at(b).to_datetime.month, Time.at(b).to_datetime.year) - 1) * 86400
      tt << Time::days_in_month(Time.at(d).to_datetime.month, Time.at(d).to_datetime.year)
    end
    t << date_end
    
    mfaktor = 0
    i       = 0
    while i < t.size
      mfaktor += self.calc_score_1(t[i], t[i+1], money_begin, tt[i/2], kontonummer)
      i += 2
    end
    
    return mfaktor
  end
  
  def self.calc_score_1(date_begin, date_end, money_begin, months_days, kontonummer)
    db_begin    = KklVerlauf.find(:all, 
      :conditions => ["ktoNr = ? AND kklAbDatum <= ?", kontonummer, date_begin], 
      :order => "kklAbDatum DESC"
    ).first

    db_duration = KklVerlauf.find(:all, 
      :conditions => ["ktoNr = ? AND kklAbDatum <= ? AND kklAbDatum > ?", kontonummer, date_end, date_begin], 
      :order => "kklAbDatum ASC"
    )
    
    t = Array.new
    t << date_begin
    t << db_begin.kkl
    
    db_duration.each do |temp1|
      t << temp1.kklAbDatum
      t << temp1.kkl
    end
    
    t << date_end.tomorrow
    t << "dummy"
    
    # hole die prozentsätze
    mfaktor = 0
    scores  = 0
    i       = 0
    while i < (t.size - 2)
      # 01.2011: beim neg. Saldo keine berücksichtigung der KKL-Prozenzsatzes, stattdessen immer KKL 100% annehmen
      if (money_begin >= 0)
        mfaktor = self.calc_percentage(t[i], t[i+2], t[i+1]) # Anzahl der Tage um KKL-Prozentsatz verringern
      else
        mfaktor = self.count_days_exact(t[i], t[i+2]) # Volle Anzahl der Tage als Faktor nehmen
      end
      
      scores += mfaktor * (money_begin / 30)
      i += 2
    end
    
    return scores
  end
  

  # Ermittelt gemittelten Faktor des Prozentsatzes einer Kontenklasse über eine Periode

  def self.calc_percentage(date_begin, date_end, kkl)
    db_begin    = Kontenklasse.find(:all, 
      :conditions => ["kkl = ? AND kklAbDatum <= ?", kkl, date_begin], 
      :order => "kklAbDatum DESC", 
      :limit => 1
    ).first

    db_duration = Kontenklasse.find(
      :all, 
      :conditions => ["kkl = ? AND kklAbDatum <= ? AND kklAbDatum > ?", kkl, date_end, date_begin], 
      :order => "kklAbDatum ASC"
    )
    
    t = Array.new
    db_duration.each do |temp1|
      t << temp1.kklAbDatum
      t << temp1.prozent
    end
    
    t << date_end
    t << "dummy"
    
    # rechne gemittelte Tage
    mtage = 0
    i = 0
    while i < (t.size - 2)
      mtage += (self.count_days_exact(t[i], t[i+2])) * (t[i+1] / 100)
      i += 2
    end
    
    return mtage
  end

  # Berechnet Anzahl der Tage zwischen zwei Datumsangaben auf der Grundlage 360 Tage im Jahr und 30 Tage im Monat
  # Simuliert Excel-Funktion TAGE360(datum,datum,art)

  def self.count_days_exact(first_time, second_time)
    # Es wurde beobachtet, dass das Ergebnis mit Nachkommastellen berechnet wird => Rundung nötig!
    return ((second_time.to_time.to_i - first_time.to_time.to_i) / 86400.0).round(0) # integer / float => float
  end

end