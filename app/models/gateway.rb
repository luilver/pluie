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
end
