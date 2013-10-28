require 'spec_helper'
require 'Punkteberechnung'

describe Punkteberechnung, "#calculate()" do
  it "returns 233" do
    date_begin = "2008-07-15".to_time
    date_end = "2008-06-05".to_time
    amount = 1000
    account_number = 70013

    points = Punkteberechnung::calculate(date_begin, date_end, amount, account_number)
    
    expect(points).to eq 233
  end 
end
