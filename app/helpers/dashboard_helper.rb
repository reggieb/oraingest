module DashboardHelper

  # uses the type of an item to generate a corresponding CSS tag to be used in
  # the dashboard view
  #
  # @note returned tag must match the one found in styles.scss:
  # @param review_item [Hash] the review item (dataset/thesis/etc) to be processed
  # @return  [ String ] the generated tag, or an empty string if the argument is nil
  def get_type_tag(item_type)
    item_type ? item_type.downcase.gsub(%r{\s}, '-').prepend('tag-')
    : ""
  end

  # uses the status of an item to generate a corresponding CSS tag to be used # in the dashboard view
  #
  # @note (see #get_type_tag)
  # @param (see #get_type_tag)
  # @return (see #get_type_tag)
  def get_status_tag(item_status)
    item_status ? item_status.downcase.gsub(%r{\s}, '-').prepend('tag-')
    : ""
  end



  def add_facets_to_query_string(facet, constraint_name)
    unless session[:solr_query_params][facet] == constraint_name
      hsh = {}
      hsh[facet] = constraint_name
      session[:solr_query_params].merge!(hsh)
    end
    session[:solr_query_params].to_query
  end

  def remove_facets_to_query_string(facet, constraint_name)
    if session[:solr_query_params][facet] == constraint_name
      session[:solr_query_params].delete(facet)
    end
    session[:solr_query_params].to_query
  end

end
