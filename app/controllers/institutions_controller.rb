class InstitutionsController < ApplicationController
  def home
    @url = Rails.env.production? ? request.host : 'http://localhost:3000'
    @inputs = {
      military_status: 'veteran',
      spouse_active_duty: 'no',
      gi_bill_chapter: '33',
      cumulative_service: '1.0',
      enlistment_service: '3',
      consecutive_service: '0.8',
      elig_for_post_gi_bill: 'no',
      number_of_dependents: 0,
      online_classes: 'no',
      institution_search: ''
    }
  end

  def autocomplete
    search_term = params[:term]

    results = Institution.autocomplete(search_term)
    respond_to do |format|
      format.json { render json: results }
    end
  end

  def search
    @inputs = { 
      military_status: params[:military_status],
      spouse_active_duty: params[:spouse_active_duty],
      gi_bill_chapter: params[:gi_bill_chapter],
      cumulative_service: params[:cumulative_service],
      enlistment_service: params[:enlistment_service],
      consecutive_service: params[:consecutive_service],
      elig_for_post_gi_bill: params[:elig_for_post_gi_bill],
      number_of_dependents: params[:number_of_dependents],
      online_classes: params[:online_classes],
      institution_search: params[:institution_search]
    }

    @schools = []

    @types = InstitutionType.pluck(:name).uniq
    @countries = []
    @states = []

 #   if @inputs[:institution_search].present?
      @schools = Institution.search(@inputs[:institution_search])
 
      @schools.each do |school|
        school[:student_veteran] = to_bool(school[:student_veteran])
        school[:poe] = to_bool(school[:poe])
        school[:yr] = to_bool(school[:yr])
        school[:eight_keys] = to_bool(school[:eight_keys])

        @states << school[:state] if school[:state].present?
        @countries << school[:country] if school[:country].present?
      end
#    end

    @countries = @countries.uniq
    @states = @states.uniq
    
    respond_to do |format|
      format.json { render json: @schools }
      format.html
    end
  end

  def to_bool(val)
    %w(yes true t 1).include?(val.to_s)
  end
end
