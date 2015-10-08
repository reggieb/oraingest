
# FIXME: ugly hack to get Solr working with Kaminari
class RSolr::Response::PaginatedDocSet
  attr_reader :limit_value
end

class FredDashboardController < ApplicationController
  def index
    @solr_connection ||= RSolr.connect url: ENV['url']
    session[:solr_query_params] ||= {}



    def restrict_access_to_reviewers
      unless can? :review, :all
        raise  CanCan::AccessDenied.new("You do not have permission to review submissions.", :review_submissions, current_user)
      end
    end


    #if no search params are passed ,then do default search
    if params.size < 3 #controller and action are always passed
      session[:solr_query_params][:status] = 'Claimed'
      session[:solr_query_params][:creator] = 'Joe+Pitt-Francis'
      # session[:solr_query_params][:creator] = 'Joe Pitt-Francis'
      @default_query = "(MediatedSubmission_status_ssim:Claimed AND
                desc_metadata__creatorName_tesim:Joe+Pitt-Francis)"
    else # user selected search parameters
      params.each do |k, v|
        if k == 'query_add'
          facet = v.keys[0]
          value = v[facet]
          session[:solr_query_params][facet.to_sym] = value
        end
        if k == 'query_remove'
          facet = v.keys[0]
          value = v[facet]
          if session[:solr_query_params].has_key?(facet.to_sym)
            session[:solr_query_params].delete(facet.to_sym)
          end
        end
      end
    end


    response = do_search

    @enable_search_form = false #stop ora search form appearing
    @number_items_found =  response['response']['numFound']

    if @number_items_found > 0
      @result_list = response['response']['docs']
      @facets = process_facets( response['facet_counts']['facet_fields'] )
    else
      # TODO: deal with error
    end

  end


  private

  def do_search
    query =  @default_query || set_query
    logger.info "Solr search query: #{query}"
    page = 1 unless params[:page]


    @solr_connection.paginate page, 10, "select", params: {
      q: query,
      facet: true,
      'facet.field' => SolrFacets.values,
      'facet.limit' => 20,
      wt: "ruby"
    }

  end


  def build_query
    idx, query = 0, "*:*"
    if session[:solr_query_params] && session[:solr_query_params].size > 0
      session[:solr_query_params].each do |k, v|
      end
    end
  end

  def set_query
    idx, query = 0, "*:*"
    if session[:solr_query_params] && session[:solr_query_params].size > 0
      session[:solr_query_params].each do |k, v|
        field = Solrium.lookup(k.to_sym) #get solr field name
        txt = v.gsub(%r{\s}, '+')
        if idx > 0
          query = "#{query} AND #{field}:#{txt}"
        else
          query = "#{field}:#{txt}"
        end
        idx = idx + 1
      end
    else
      logger.warn ">>> SolrSearch#search, query_hash is nil or empty \
            - defaulting to global search"
    end
    query
  end

  # Creates a Hash where the key is the facet and the value is a Hash
  # containing the facet's constraints
  #
  # @param facet_hash [Hash] the Solr-style facet Hash in the {facet [Hash]:
  # constraints [Array]} style
  # @return [Hash] a Hash in the {facet [Hash]: constraints [Hash]} style
  def process_facets(facet_hash)
    facets = {}
    facet_hash.each do |facet, facet_constraints|
      # Solrium.reverse_lookup(facet)
      if facet_constraints.size > 0
        facets[facet] = convert_constraints_array(facet_constraints)
      end
    end
    facets
  end


  # Converts a Solr-style facet costraints array into a more
  # meaningful Hash
  #
  # @param constraints_arr [Array] a Solr-style facet costraints array
  # @return [Hash] a Hash in the {constraint_name: count} style
  def convert_constraints_array(constraints_arr)
    constraints_hash = {}
    constraints_arr.each_with_index do |x, idx|
      if idx.even?
        constraints_hash[x] = constraints_arr[idx+1]
      end
    end
    constraints_hash
  end

end
