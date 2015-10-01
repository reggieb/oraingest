class SolrSearch
  include ActiveModel::Model

  attr_writer :query, :solr_connection

  # validates :email, presence: true, length: {in:2..255}


  def initialize(attributes={})

	@facet_fields = [
		"desc_metadata__type_sim", 
		"MediatedSubmission_status_ssim", 
		"desc_metadata__creator_sim", 
		"desc_metadata__keyword_sim", 
		"desc_metadata__subject_sim", 
		"desc_metadata__language_sim", 
		"desc_metadata__based_near_sim", 
		"desc_metadata__publisher_sim", 
		"active_fedora_model_ssi", 
		"MediatedSubmission_current_reviewer_id_ssim", 
		"MediatedSubmission_all_reviewer_ids_ssim"
	]

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

  def search(search_params, page)



      page = 1 unless page	
      @solr_connection.paginate page, 10, "select", params: { q: "desc_metadata__title_tesim:\"disaster\"", 
      	facet: true, 
      	:'facet.field' => @facet_fields,
      	wt: "ruby"}

  end

end
