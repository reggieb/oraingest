class SolrSearch
  include ActiveModel::Model

  attr_writer :query, :solr_connection

  # validates :email, presence: true, length: {in:2..255}

  def initialize(attributes={})

    @joined_queries = 0
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

  def set_query(query_hash)
    if query_hash.is_a?(Hash) && (query_hash.size == 1)
      key = query_hash.keys[0]
      field = Solrium.find(key) #get solr field name
      txt = query_hash[key].gsub(%r{\s}, '+')
      if @joined_queries == 0
        @query = "#{field}:#{txt}"
      elsif @joined_queries > 0
        @query = "#{@query} AND #{field}:#{txt}"
      end
      @joined_queries = @joined_queries + 1
    end
  end


  def search(page)

    page = 1 unless page
    solr_params["facet.limit"].to_i

    unless @query
      logger.info ">>> SolrSearch#search, query_hash is nil - defaulting to global search"
      @query = "*:*"
    end

    @solr_connection.paginate page, 10, "select", params: {
      q: @query,
      facet: true,
      'facet.field' => @facet_fields,
      'facet.limit' => 20,
      wt: "ruby"
    }

  end

end
