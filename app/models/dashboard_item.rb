class DashboardItem
  include ActiveModel::Model


  Solrium.each do |nice_name, solr_name|
  	attr_reader nice_name.to_s.downcase.to_sym
  end

  def initialize(solr_response_item)
    Solrium.each do |nice_name, solr_name|
      self.instance_variable_set("@#{nice_name.to_s.downcase}", solr_response_item[solr_name])
    end
  end

end
