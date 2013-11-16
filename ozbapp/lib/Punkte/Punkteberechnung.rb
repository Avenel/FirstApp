class Punkteberechnung

  # Calculates a rounded score per default. If you want to have the exact score set round_down to false.
  def self.calculate(date_begin, date_end, amount, account_number, round_down = true)
    exact_score = self.calc_score_new(date_begin, date_end, amount, account_number)

    if(round_down)
      return exact_score.to_i
    else
      return exact_score
    end
  end

  # Calculates the exact score.
  def self.calc_score_new(date_begin, date_end, amount, account_number)
    account_class_changes = get_affected_account_class_changes(date_begin, date_end, account_number)
    days_in_account_classes = get_days_in_account_classes(account_class_changes, date_begin, date_end)

    score = 0

    days_in_account_classes.each_with_index do |(account_class, days), i|
      factor = get_factor_for_account_class(account_class_changes[i].kontenklasse)
      score += days/30.0 * amount * factor
    end

    return score
  end

  # Returns the factor for an account class. E.g. class B --> 0.75
  def self.get_factor_for_account_class(account_class) 
    account_class.Prozent / 100
  end

  # Calculates the days spent in the given account classes.
  def self.get_days_in_account_classes(account_class_changes, date_begin, date_end)
    days_in_account_classes = Hash.new 
    
    account_class_changes.each_with_index do |account_class, i|
      from_date = i == 0 ? date_begin : account_class.KKLAbDatum
      to_date = account_class_changes[i+1].nil? ? date_end : account_class_changes[i+1].KKLAbDatum

      days_in_account_classes[account_class.KKL] = count_days_exact(from_date, to_date)

      if (i > 0) # add one day between an account class change.
        days_in_account_classes[account_class.KKL] = days_in_account_classes[account_class.KKL] + 1
      end

    end
    return days_in_account_classes
  end

  # Retrieves the account class changes for the given dates and account number
  def self.get_affected_account_class_changes(date_begin, date_end, account_number) 
    first_account_class_change = KklVerlauf.find(:all, 
      :conditions => ["KtoNr = ? AND KKLAbDatum <= ?", account_number, date_begin], 
      :order => "KKLAbDatum DESC"
    ).first

    following_account_class_changes = KklVerlauf.find(:all, 
      :conditions => ["KtoNr = ? AND KKLAbDatum <= ? AND KKLAbDatum > ?", account_number, date_end, date_begin], 
      :order => "KKLAbDatum ASC"
    )

    all_account_class_changes = Array.new
    all_account_class_changes << first_account_class_change
    all_account_class_changes << following_account_class_changes

    return all_account_class_changes.flatten
  end

  # Calculates the days between two dates.
  def self.count_days_exact(first_time, second_time)
    return ((second_time.to_time - first_time.to_time) / 1.day).to_i
  end
end
