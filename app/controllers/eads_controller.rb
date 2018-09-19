require 'byebug'

class EadsController < ApplicationController
  def index
    @results = ActiveFedora::SolrService.query("has_model_ssim:Collection", fl: 'id,ead_tesim,title_tesim', rows: 10_000)
  end
end
