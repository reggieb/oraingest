# FIX: ugly hack to get Solr working with Kaminari
class RSolr::Response::PaginatedDocSet
  attr_reader :limit_value
end

class DashboardController < ApplicationController
  def index
    s = SolrSearch.new
    # s.set_query depositor: 'qa@bodleian.com'
    # s.set_query status: 'Claimed'
    s.set_query title: 'disaster'


    response =  s.search(params[:page])


    @enable_search_form = false #stop ora search form appearing
    @number_items_found =  response['response']['numFound']

    if @number_items_found > 0
      fc = response['facet_counts']['facet_fields']
      @result_list = response['response']['docs']
      d = DashboardItem.new(@result_list[0]) 
    else
      # TODO deal with error
    end


  end

end

# 