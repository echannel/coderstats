class Tracker < ActiveRecord::Base
  attr_accessible :code, :name, :points

  def self.get(code, name = code.capitalize)
    tracker = where(:code => code).first
    tracker || create(:name => name, :code => code, :points => 1)
  end
end
