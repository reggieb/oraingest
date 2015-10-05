# FIX: ugly hack to get Solr working with Kaminari
class RSolr::Response::PaginatedDocSet
  attr_reader :limit_value
end

class DashboardController < ApplicationController
  def index
    s = SolrSearch.new


    if params[:search]
      parsed_search_params = params[:search].rpartition(":")
      search_field = parsed_search_params[0] #
      search_value = parsed_search_params[2] #
    else #default search
		search_field = :status
		search_value = 'Claimed'
    end
    s.set_query search_field, search_value
    s.set_query :creator, "Joe Pitt-Francis"



    response =  s.search(params[:page])

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
