require 'spec_helper'
require 'Punkteberechnung'

describe Punkteberechnung, "#calculate()" do
  it "returns 233" do
    date_begin = "2008-07-15".to_time
    date_end = "2008-08-05".to_time
    amount = 1000
    account_number = 70013

    points = Punkteberechnung::calculate(date_begin, date_end, amount, account_number)
    
    expect(points).to eq 233
  end 
end

describe Punkteberechnung, "#get_affected_account_classes()" do
  it "returns B and C as affected account classes" do
    date_begin = "2008-07-15".to_time
    date_end = "2008-08-05".to_time
    account_number = 70013

    account_classes = Punkteberechnung::get_affected_account_classes(date_begin, date_end, account_number)
    
    expect(account_classes[0].KKL).to eq 'B'
    expect(account_classes[1].KKL).to eq 'C'
  end 
end

describe Punkteberechnung, "#get_days_in_account_classes()" do
  it "returns 16 for class B and 5 for class C" do
    date_begin = "2008-07-15".to_time
    date_end = "2008-08-05".to_time
    account_number = 70013
	account_classes = Punkteberechnung::get_affected_account_classes(date_begin, date_end, account_number)
    
    days_in_account_classes = Punkteberechnung::get_days_in_account_classes(account_classes)
    
    expect(days_in_account_classes["B"]).to eq 16
    expect(days_in_account_classes["C"]).to eq 5
  end 
end
