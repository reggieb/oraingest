module DashboardHelper

  def get_type_tag(item_type)
  	item_type.downcase.gsub(%r{\s}, '-').prepend('tag-')
  end

  def get_status_tag(item_status)
  	item_status.downcase.gsub(%r{\s}, '-').prepend('tag-')
  end


end
