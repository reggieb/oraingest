class DashboardController < ApplicationController
  def index
    s = SolrSearch.new
    # s.search_term = "uuid:d640713e-9a34-4ab2-afcf-317dc5f5af12"

 params = {qt: "search", rows: 10, "spellcheck.q"=>nil, facet: true, :"facet.field"=>["desc_metadata__type_sim", "MediatedSubmission_status_ssim", "desc_metadata__creator_sim", "desc_metadata__keyword_sim", "desc_metadata__subject_sim", "desc_metadata__language_sim", "desc_metadata__based_near_sim", "desc_metadata__publisher_sim", "active_fedora_model_ssi", "MediatedSubmission_current_reviewer_id_ssim", "MediatedSubmission_all_reviewer_ids_ssim"], :"f.desc_metadata__type_sim.facet.limit"=>11, :"f.MediatedSubmission_status_ssim.facet.limit"=>16, :"f.desc_metadata__creator_sim.facet.limit"=>11, :"f.desc_metadata__keyword_sim.facet.limit"=>11, :"f.desc_metadata__subject_sim.facet.limit"=>11, :"f.desc_metadata__language_sim.facet.limit"=>6, :"f.desc_metadata__based_near_sim.facet.limit"=>11, :"f.desc_metadata__publisher_sim.facet.limit"=>11, :"f.active_fedora_model_ssi.facet.limit"=>11, :"f.MediatedSubmission_current_reviewer_id_ssim.facet.limit"=>6, :"f.MediatedSubmission_all_reviewer_ids_ssim.facet.limit"=>6, sort: "score desc, system_create_dtsi desc"}#, 
 	 # fq: ["active_fedora_model_ssi:Article OR active_fedora_model_ssi:Dataset", "-MediatedSubmission_status_ssim:Draft"]}

    search_params = { q: "depositor_tesim:bodl2339",
  					start: 0,
  					rows: 10
  					}
    # search_params = {q: "id:uuid:d640713e-9a34-4ab2-afcf-317dc5f5af12"}
    # @response =  s.search params.merge(q: 'desc_metadata__contributor_tesim:bodl1087')
    @response =  s.search search_params

  end

end
