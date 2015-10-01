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


  # if the text exceeds the limit it will slice the text to the limit and append some continuation characters (...). If the text is less than the limit it is returned unchanged. Used to display text fields in the view
  #
  # @param txt [String] the text to trim
  # @param limit [FixNum] the limit to trim to
  # @return [String] the trimmed or untrimmed text
  def trim_text(txt, limit)
    if txt
      txt = (txt.size > limit) ?
        (txt.slice(0, limit ) + "...") :
        txt
    else
      txt = ""
    end
  end

  # examines a review item to determine which date can be displayed on teh dashboard view
  #
  # @param review_item [Hash] the review item (dataset/thesis/etc) to be processed
  # @return  date_list [ Array ] first element is the type of date, second is the actual date
  def determine_date(review_item)
    date_list = []
    if review_item
	    if review_item['desc_metadata__datePublished_tesim']
	      date_list = ['published', review_item['desc_metadata__datePublished_tesim'].first]
	    elsif
	      review_item['desc_metadata__dateAccepted_tesim']
	      date_list = ['accepted', review_item['desc_metadata__dateAccepted_tesim'].first]
	    else
	      date_list = ['not_found']
	    end
	end
    date_list
  end

  def is_item_claimed?(review_item)
    review_item ? review_item['MediatedSubmission_status_ssim'].first : false
  end

end
