class GroupByAreaType < Jekyll::Generator
  def generate(site)
    ocd_ids = CSV.parse(open('https://github.com/theyworkforyou/uganda_ocd_ids/raw/master/identifiers/country-ug.csv').read, headers: true, header_converters: :symbol)
    ocd_mapping = Hash[ocd_ids.map { |id| [id[:id], id[:name]] }]
    # Group current memberships by district
    memberships_by_district = site.collections['memberships'].docs.reject { |d| !d['area_id'] }.group_by do |d|
      d['area_id'] && d['area_id'].split('/').slice_after(/^district\:/).first.join('/')
    end
    # Create a new collection
    collection_name = 'districts'
    collection = Jekyll::Collection.new(site, collection_name)
    memberships_by_district.each do |id, memberships|
      path = File.join(site.source, "_#{collection_name}", "#{Jekyll::Utils.slugify(id)}.md")
      doc = Jekyll::Document.new(path, collection: collection, site: site)
      doc.merge_data!('name' => ocd_mapping[id] || id, 'memberships' => memberships)
      if site.layouts.key?(collection_name)
        doc.merge_data!('layout' => collection_name)
      end
      collection.docs << doc
    end
    collection.docs = collection.docs.sort_by { |d| d['name'] }
    site.collections[collection_name] = collection
  end
end
