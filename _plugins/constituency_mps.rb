require 'pry'

module Jekyll
  class ConstituencyMps < Generator
    def generate(site)
      most_recent_term = site.collections['events'].docs.find { |d| d.data['end_date'].nil? }
      site.collections['areas'].docs.each do |area|
        current, historic = area.data['memberships'].partition { |m| m['legislative_period'] == most_recent_term }
        area.data['current_membership'] = current.first
        area.data['historic_memberships'] = historic
      end
    end
  end
end
