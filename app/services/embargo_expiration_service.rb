# An automated service that:
# 1. Checks the repository for works that will expire in 60 days, 7 days, or today
# 2. If a work expires in 60 days or 7 days, send the appropriate notification
# 3. If the work expires today, send the appropriate notification and remove the embargo
# 4. Send a summary report to the application admins
# @example How to call this service
#  # Run today's notifications
#  EmbargoExpirationService.run
#  # Run yesterday's notifications
#  EmbargoExpirationService.run(Time.zone.today - 1.day)
class EmbargoExpirationService
  attr_reader :summary_report, :summary_report_subject
  # Run the service. By default, it will check expirations against today.
  # You can also pass in a date.
  # @param [Date] date the date by which to measure expirations
  def self.run(date = nil)
    rundate =
      if date
        Date.parse(date)
      else
        Time.zone.today
      end
    Rails.logger.info "Running embargo expiration service for #{rundate}"
    EmbargoExpirationService.new(rundate).run
  end

  # Format a Date object such that it can be used in a solr query
  # @param [Date] date
  # @return [String] date formatted like "2017-07-27T00:00:00Z"
  def solrize_date(date)
    date.strftime('%Y-%m-%dT00:00:00Z')
  end

  def initialize(date)
    @date = date
    @summary_report = "Summary embargo report for #{date}\n"
    @summary_report_subject = "MIRA/TDR Embargos Summary: #{date}"
  end

  # Given a work, format it for inclusion in the summary report
  def format_for_summary_report(work)
    "\n Embargo Release Date: #{work.embargo.embargo_release_date}\n Creator: #{work.creator.first}\n Title: #{work.title.first}\n ID: #{work.id} \n\n"
  end

  def run
    items = find_expirations
    report_and_expire unless items.empty?
  end

  def report_and_expire
    create_summary_report
    expire_embargoes
    send_summary_report
  end

  def create_summary_report
    @summary_report << "\n"
    expirations = find_expirations
    expirations.each do |expiration|
      @summary_report << format_for_summary_report(expiration)
    end
  end

  def send_summary_report
    Hyrax::Workflow::EmbargoSummaryReportNotification.send_notification(@summary_report_subject, @summary_report)
  end

  def expire_embargoes
    expirations = find_expirations
    expirations.each do |expiration|
      Rails.logger.warn "ETD #{expiration.id}: Expiring embargo"
      expiration.visibility = expiration.visibility_after_embargo if expiration.visibility_after_embargo
      expiration.deactivate_embargo!
      expiration.embargo.save
      expiration.save
    end
  end

  # Find all ETDs what will expire in the given number of days
  # @param [Integer] number of days
  def find_expirations
    days_to_check = Array(1..180)
    items = []
    days_to_check.each do |day|
      expiration_date = solrize_date(@date - day.send(:days))
      items += ActiveFedora::Base.where("embargo_release_date_dtsi:#{RSolr.solr_escape(expiration_date)}")
    end
    items
  end
end
