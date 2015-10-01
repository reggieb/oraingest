    class RSolr::Response::PaginatedDocSet
    	attr_reader :limit_value
    end

class DashboardController < ApplicationController
  def index
    s = SolrSearch.new

    search_params = { q: "desc_metadata__title_tesim:\"disaster\"",
  					start: 0,
  					rows: 10
  					}
    response =  s.search(search_params, params[:page])


    @enable_search_form = false #stop ora search form appearing
    @number_items_found =  response['response']['numFound']
    if @number_items_found > 0
    	binding.pry
    	 fc = response['facet_counts']['facet_fields']
	    @result_list = response['response']['docs'] 
	else
		# TODO deal with error
	end


  end

end
