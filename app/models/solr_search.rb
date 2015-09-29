class SolrSearch
  include ActiveModel::Model

  attr_writer :query, :solr_connection

  # validates :email, presence: true, length: {in:2..255}


  def initialize(attributes={})
    super
    @solr_connection ||= RSolr.connect url: ENV['url']
  rescue => e
    logger.fatal e.message
  end

  def search_term=(term)
  	@query[:q] = (term.is_a? String && term.size > 0) ?  
  					term : 
  					'*:*'
  end


  def limit_fields
  end

  def filter
  end

  def search(search_params)
  	@solr_connection.get 'select',
  				params: search_params.merge(wt: "ruby")
  end

  private




end
