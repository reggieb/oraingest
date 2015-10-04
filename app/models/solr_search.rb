  # This class abstracts the data and logic needed to make a Solr search
  # query.  
  #

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


  # Constructs a Solr query argument (q). Will create joined (AND)
  # arguments if called repeatedly.
  #
  # @note method depends on the Solrium module to translate the human
  # readable key value to its Solr equivalent
  # @param query_hash [Hash] the query hash in the form of
  # {human_readable_field_title: value}. E.g. {creator: 'fred'}
  # @return [String] a valid Solr query value
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
