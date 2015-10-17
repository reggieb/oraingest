require "net/http"

# FIXME: ugly hack to get Solr working with Kaminari
class RSolr::Response::PaginatedDocSet
  attr_reader :limit_value
end



class FredDashboardController < ApplicationController

  before_filter :restrict_access_to_reviewers

  def index
    @solr_connection ||= RSolr.connect url: ENV['url']
    @default_search = {status: 'Claimed', creator: current_user.email}
    session[:solr_query_params] ||= {}
    @solr_docs = []


    total = @solr_connection.select({:rows => 0})["response"]["numFound"]
    rows  = 100



    pages = (total.to_f / rows.to_f).ceil # round up
    (1..pages).each do |page|
      start = (page-1) * rows
      query_string = "/select?q=*%3A*&rows=#{rows}&start=#{start}&wt=ruby"
      # need to remove # from url, or it won't work
      sanitised_url = ENV['url'].gsub(%r{/#}, '')
      response = http_request(sanitised_url + query_string)
      if response.is_a? Net::HTTPSuccess 
        #body is a Hash wrapped in a String, so eval will give us the Hash
        solr_hash = eval(response.body) 
        @facets = process_facets( solr_hash['facet_counts']['facet_fields'] )
        solr_hash['response']['docs'].each do |solr_doc|
          @solr_docs << SolrDoc.new(solr_doc)
        end
      else
        # TODO: deal with error
      end
    end

    if params[:q]  
      query_string = params[:q]
    else
      query_string = "status=Claimed,creator=#{current_user.email}" 
    end
    results = QueryStringSearch.new(@solr_docs, query_string).results
    binding.pry

    @result_list = Kaminari.paginate_array(results, total_count: pages).page(params[:page]).per(10)

    @enable_search_form = false #stop ora search form appearing


  end



  def do_search(query)
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

  def http_request(url, limit = 10)

    raise ArgumentError, 'HTTP redirect too deep' if limit == 0

    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.request_uri)

    response = http.request(request)

    if response.is_a? Net::HTTPSuccess 
      response
    elsif response.is_a? Net::HTTPRedirection 
      http_request(response['location'], limit - 1)
    else
      response.error!
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



  def full_search_query(term)
    q_string = ""
    Solrium.values.each_with_index do |solr_field, i|
      q_string = q_string + "#{solr_field}:#{term}"
      q_string = q_string + " OR " unless i == Solrium.values.size - 1
    end
    q_string
  end

  def restrict_access_to_reviewers
    unless can? :review, :all
      raise  CanCan::AccessDenied.new("You do not have permission to review submissions.", :review_submissions, current_user)
    end
  end

end
