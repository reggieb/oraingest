
  # This module is responsible for mapping between Solr-style field names and
  # sensible attribyte names for our objects and views. Can be used to 
  # quickly initialize classes, e.g. see DashboardItem 
  #

module Solrium
  def self.add_item(key,value)
    @hash ||= {}
    @hash[key]=value
  end

  def self.const_missing(key)
    @hash[key]
  end

  def self.each
    @hash.each {|key,value| yield(key,value)}
  end

  def self.find(field)
    @hash.fetch(field.to_s.upcase.to_sym)
  end

  self.add_item :STATUS, 'MediatedSubmission_status_ssim'
  self.add_item :TITLE, 'desc_metadata__title_tesim'
  self.add_item :TYPE, 'desc_metadata__type_tesim'
  self.add_item :ABSTRACT, 'desc_metadata__abstract_tesim'
  self.add_item :DEPOSITOR, 'depositor_tesim'
  self.add_item :DATE_PUBLISHED, 'desc_metadata__datePublished_tesim'
  self.add_item :DATE_ACCEPTED, 'desc_metadata__dateAccepted_tesim'
  self.add_item :CREATOR, 'desc_metadata__creatorName_tesim'
  self.add_item :REVIEWER, 'MediatedSubmission_current_reviewer_id_ssim'
  self.add_item :RT_TICKETS, 'MediatedSubmission_all_email_threads_ssim'
end

