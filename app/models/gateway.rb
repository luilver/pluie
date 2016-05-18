class Gateway < ActiveRecord::Base
  has_many :users
  has_many :routes
  has_many :users, :through => :routes
  has_many :gateway_prefixtables, -> {distinct}
  has_many :prefix_tables, -> {distinct}, :through => :gateway_prefixtables
  validates :name, presence: true
  validates :name, uniqueness: { case_sensitive: false }
  validates :price, numericality: { greater_than: 0 }

  def to_s
    self.name
  end

  def price_gateway(prefix)
    return nil if PrefixTable.find_by_country_code(prefix).blank?
    route_table=PrefixTable.find_by_country_code(prefix)
    self.gateway_prefixtables.where(:prefix_table_id=> route_table.id).first.price.to_f || nil
  end

  def get_prefix(phone_number)
    prefix=[phone_number[0..2],phone_number[0..1],phone_number[0..0]]
    prefix.each do |prf|
      if self.prefix_tables.where(:country_code=>prf).any?
        return self.price_gateway(prf)
      end
    end
    return nil
  end

   #asignar precio de sistema tiene que ser mayo que el menor precio de costo del gateway a ese pais
  def assign_ps(params)
     prefix=PrefixTable.find(params[:prefix_list].to_i)
     price_cost_low=GatewayPrefixtable.where(:prefix_table_id=>prefix.id).order(:price_cost=>:desc).first.price_cost
     #
     if price_cost_low > params[:price_prefix].to_f and params[:price_prefix] !=0.0
       return false,price_cost_low
     end
     prefix_id=params[:prefix_list]
     g=GatewayPrefixtable.find_or_create_by(:gateway_id=>self.id,:prefix_table_id=>prefix_id)
     g.price_system=params[:price_prefix].to_f > price_cost_low ? params[:price_prefix] : price_cost_low
     g.price_cost=params[:price_cost].to_f!=0.0 ? params[:price_cost].to_f : price_cost_low
     g.save
     return true
  end
end
