module Jekyll
  class CurrentHistoricPeople < Generator
    CURRENT_MP_LAYOUT = 'current_mp'
    HISTORIC_MP_LAYOUT = 'historic_mp'

    def generate(site)
      most_recent_term = site.collections['events'].docs.find { |d| d.data['end_date'].nil? }
      site.collections['people'].docs.each do |person|
        if person.data['memberships'].any? { |m| m['legislative_period'] == most_recent_term }
          person.data['layout'] = CURRENT_MP_LAYOUT
          person.data['current_membership'] = person.data['memberships'].find { |m| m['legislative_period'] == most_recent_term }
        else
          person.data['layout'] = HISTORIC_MP_LAYOUT
        end
      end
    end
  end
end
