module HistoricRecord

  def set_valid_time
    unless(self.GueltigBis || self.GueltigVon)
      self.GueltigVon = Time.now
      self.GueltigBis = Time.zone.parse("9999-12-31 23:59:59")
    end
  end

  @@copy = nil

  def set_new_valid_time
    @@copy = nil 
    if (self.GueltigBis > "9999-01-01 00:00:00")
      latestObject = self.getLatest()
      @@copy       = latestObject.dup

      # set primary keys
      val = latestObject.send(:get_primary_keys)
      @@copy.send(:set_primary_keys, val)

      @@copy.GueltigVon = self.GueltigVon
      @@copy.GueltigBis = Time.now

      self.GueltigVon   = Time.now
      self.GueltigBis   = Time.zone.parse("9999-12-31 23:59:59")
    end
  end

  def save_copy
    puts ">>>> DEBUG save_copy " + self.class.name
    if !@@copy.nil?
      begin      
        @@copy.save(:validation => false)
        @@copy = nil
      rescue Exception => e
        puts ">>>>>> FAIL SAVE COPY " + self.class.name
        puts e.message
      end
    end
  end

end