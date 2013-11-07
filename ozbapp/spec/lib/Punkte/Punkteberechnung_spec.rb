require 'spec_helper'
require 'Punkteberechnung'

describe Punkteberechnung, "#calculate()" do
  it "returns 483" do
    date_begin = "2008-07-15".to_time
    date_end = "2008-08-05".to_time
    amount = 1000
    account_number = 70013

    points = Punkteberechnung::calculate(date_begin, date_end, amount, account_number)
    
    expect(points).to eq 483
  end 
end

describe Punkteberechnung, "#calc_score()" do
  it "returns 483" do
    date_begin = "2008-07-15".to_time
    date_end = "2008-08-05".to_time
    amount = 1000
    account_number = 70013

    points = Punkteberechnung::calc_score(date_begin, date_end, amount, account_number)
    
    expect(points).to eq 483
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
    
    days_in_account_classes = Punkteberechnung::get_days_in_account_classes(account_classes, date_begin, date_end)
    
    expect(days_in_account_classes["B"]).to eq 16
    expect(days_in_account_classes["C"]).to eq 5
  end 

  it "works for a longer period with more than 2 account classes"

end

describe Punkteberechnung, "#get_factor_for_account_class()" do
	it "returns 0.75 for class B" do
		date_begin = "2008-07-15".to_time
    date_end = "2008-08-05".to_time
	  account_number = 70013
		account_classes = Punkteberechnung::get_affected_account_classes(date_begin, date_end, account_number)
		
		factor = Punkteberechnung::get_factor_for_account_class(account_classes[0]).to_f

		expect(factor).to eq 0.75
	end
end 

describe Punkteberechnung, "#count_days_exact()" do
  it "returns 16" do
    date_begin = "2008-07-15".to_time
    date_end = "2008-08-01".to_time
    
    days = Punkteberechnung::count_days_exact(date_begin, date_end)

    expect(days).to eq 16
  end

  it "returns 5" do
    date_begin = "2008-08-01".to_time
    date_end = "2008-08-05".to_time
    
    days = Punkteberechnung::count_days_exact(date_begin, date_end)

    expect(days).to eq 5
  end

  it "returns 31" do
    date_begin = "2013-01-01".to_time
    date_end = "2013-02-01".to_time
    
    days = Punkteberechnung::count_days_exact(date_begin, date_end)

    expect(days).to eq 31
  end
end

