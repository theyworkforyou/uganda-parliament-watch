class SortEvents < Jekyll::Generator
  def generate(site)
    site.collections['events'].docs.each do |event|
      event.data['memberships'].sort_by! { |m| m['person'].data['name'] }
    end
  end
end
