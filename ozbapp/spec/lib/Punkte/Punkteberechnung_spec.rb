require 'spec_helper'
require 'Punkteberechnung'

describe Punkteberechnung do

  it "calculates a score of 483" do
    date_begin = "2008-07-15".to_time
    date_end = "2008-08-05".to_time
    amount = 1000
    account_number = 70013

    points = Punkteberechnung.calculate(date_begin, date_end, amount, account_number)
    
    expect(points).to eq 483
  end 

  it "returns B and C as affected account classes" do
    date_begin = "2008-07-15".to_time
    date_end = "2008-08-05".to_time
    account_number = 70013

    account_classes = Punkteberechnung.get_affected_account_class_changes(date_begin, date_end, account_number)
    
    expect(account_classes[0].KKL).to eq 'B'
    expect(account_classes[1].KKL).to eq 'C'
  end 

  it "returns 5 days for class C" do
    date_begin = "2008-07-15".to_time
    date_end = "2008-08-05".to_time
    account_number = 70013
    account_classes = Punkteberechnung.get_affected_account_class_changes(date_begin, date_end, account_number)
    
    days_in_account_classes = Punkteberechnung.get_days_in_account_classes(account_classes, date_begin, date_end)
    
    expect(days_in_account_classes["C"]).to eq 5
  end 

  it "returns 16 days for class B" do
    date_begin = "2008-07-15".to_time
    date_end = "2008-08-05".to_time
    account_number = 70013
    account_classes = Punkteberechnung.get_affected_account_class_changes(date_begin, date_end, account_number)
    
    days_in_account_classes = Punkteberechnung.get_days_in_account_classes(account_classes, date_begin, date_end)
    
    expect(days_in_account_classes["B"]).to eq 16
  end 

  it "calculates the factor 1.0 for class A" do
    account_class = Kontenklasse.find("A")
    factor = Punkteberechnung.get_factor_for_account_class(account_class)
    expect(factor).to eq 1.0 
  end

	it "calculates the factor 0.75 for class B" do
		account_class = Kontenklasse.find("B")
    factor = Punkteberechnung.get_factor_for_account_class(account_class)
    expect(factor).to eq 0.75 
	end

  it "calculates the factor 0.5 for class C" do
    account_class = Kontenklasse.find("C")
    factor = Punkteberechnung.get_factor_for_account_class(account_class)
    expect(factor).to eq 0.5
  end

  it "calculates the factor 0.25 for class D" do
    account_class = Kontenklasse.find("D")
    factor = Punkteberechnung.get_factor_for_account_class(account_class)
    expect(factor).to eq 0.25
  end
  
  it "calculates the factor 0.0 for class E" do
    account_class = Kontenklasse.find("E")
    factor = Punkteberechnung.get_factor_for_account_class(account_class)
    expect(factor).to eq 0.0
  end

  it "returns 17 days" do
    date_begin = "2008-07-15".to_time
    date_end = "2008-08-01".to_time
    
    days = Punkteberechnung.count_days_exact(date_begin, date_end)

    expect(days).to eq 17
  end

  it "returns 4 days" do
    date_begin = "2008-08-01".to_time
    date_end = "2008-08-05".to_time
    
    days = Punkteberechnung.count_days_exact(date_begin, date_end)

    expect(days).to eq 4
  end

  it "returns 31 days" do
    date_begin = "2013-01-01".to_time
    date_end = "2013-02-01".to_time
    
    days = Punkteberechnung.count_days_exact(date_begin, date_end)

    expect(days).to eq 31
  end

  it "returns 366 days because 2000 was a leapyear" do
    date_begin = "2000-01-01".to_time
    date_end = "2001-01-01".to_time
    
    days = Punkteberechnung.count_days_exact(date_begin, date_end)

    expect(days).to eq 366
  end

  it "returns 365 days because 2001 was not a leapyear" do
    date_begin = "2001-01-01".to_time
    date_end = "2002-01-01".to_time
    
    days = Punkteberechnung.count_days_exact(date_begin, date_end)

    expect(days).to eq 365
  end

  it "works for a longer period with more than 2 account classes"

  it "works for more than one booking in one day"
end
