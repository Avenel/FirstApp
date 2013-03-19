module OzbKontoHelper
  
  # builds the relation objects if they're not already assigned via mass-assignment
  def setup_ee_konto(ozb_konto)
    # create new KKLVerlauf to get fields
    if (ozb_konto.kkl_verlauf.nil?)
       ozb_konto.build_kkl_verlauf # has_one
    end
    
    # create new EEKonto to get fields
    if (ozb_konto.ee_konto.nil?)
      ozb_konto.build_ee_konto # has_one
    end
    
    # create new Bankverbindung to get fields
    if (ozb_konto.ee_konto.Bankverbindung.nil?)
      ozb_konto.ee_konto.build_Bankverbindung # belongs_to
    end
    
    # create new Bank to get fields
    if (ozb_konto.ee_konto.Bankverbindung.Bank.nil?)
      ozb_konto.ee_konto.Bankverbindung.build_Bank # belongs_to
    end
    
    return ozb_konto
  end
  
  # builds the relation objects if they're not already assigned via mass-assignment
  def setup_ze_konto(ozb_konto)
    # create new KKLVerlauf to get fields
    if (ozb_konto.kkl_verlauf.nil?)
       ozb_konto.build_kkl_verlauf # has_one
    end
    
    # create new EEKonto to get fields
    if (ozb_konto.ze_konto.nil?)
      ozb_konto.build_ze_konto # has_one
    end
    
    return ozb_konto
  end
end
