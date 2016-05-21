class TableRoute < ActiveRecord::Base
  belongs_to :route

  before_save :validate_prefix_route
  before_save :validate_price_cost_vs_system
  before_save :price_system_bigger
  validates_presence_of :country_code
  validates_presence_of :name_route
  validates_presence_of :price_cost
  validates_presence_of :price_system

  def validate_prefix_route
    values_tr=TableRoute.where(:country_code=>self.country_code, :name_route=>self.name_route)
    if values_tr.count==1
      return true if self.id==values_tr.first.id
    end
    if TableRoute.where(:country_code=>self.country_code, :name_route=>self.name_route).any?
      self.errors.add(:error,'country code and route not repeat')
      return false
    end
    return true
  end

  def validate_price_cost_vs_system
    max=0
    same_prefix_gt=TableRoute.where(:country_code=>self.country_code).map {|tr| {:pc=>tr.price_cost,:gt=>tr.route.gateway.id}}
    max=same_prefix_gt.first[:pc] if same_prefix_gt.any?
    same_prefix_gt.each do |grt|
      if grt[:pc]>max
        max=grt[:pc]
      end
    end
    if self.price_system < max
      self.errors.add(:error,"price system must be bigger #{max}")
      return false
    end
    return true
  end

  def price_system_bigger
    if self.price_system < self.price_cost
      self.errors.add(:error,"price system must be bigger that price cost")
      return false
    end
    return true
  end
end
