require 'open-uri'

def available_images
  @available_images ||= begin
    index_txt_url = 'https://theyworkforyou.github.io/uganda-images/Parliament/index.txt'
    @available_images = open(index_txt_url).to_a.map(&:chomp)
  end
rescue OpenURI::HTTPError => e
  warn "Couldn't retrieve list of available images: #{e.message}"
  []
end

Jekyll::Popolo.register_popolo_file(:parliament, open(File.read('EVERYPOLITICIAN_DATASOURCE').chomp).read)

Jekyll::Popolo.process do |site, popolo|
  parliament = popolo.files[:parliament]
  people = parliament['persons'].map do |person|
    person['layout'] = 'people'
    person['title'] = person['name']
    if available_images.include?(person['id'])
      person['image'] = "https://theyworkforyou.github.io/uganda-images/Parliament/#{person['id']}.jpeg"
    else
      # If we don't have a cached version remove the image property from person
      person.delete('image')
    end
    person
  end
  popolo.create_jekyll_collections(people: people)

  memberships = parliament['memberships'].map do |membership|
    membership['person'] = site.collections['people'].docs.find { |p| p['id'] == membership['person_id'] }
    membership['party'] = parliament['organizations'].find { |o| o['id'] == membership['on_behalf_of_id'] }
    membership['legislative_period'] = parliament['events'].find { |e| e['id'] == membership['legislative_period_id'] }
    membership['post'] = parliament['posts'].find { |p| p['id'] == membership['post_id'] }
    membership['area'] = parliament['areas'].find { |a| a['id'] == membership['area_id'] }
    membership
  end
  popolo.create_jekyll_collections(memberships: memberships)

  # Associate people with their memberships
  site.collections['people'].docs.each do |person|
    person.data['memberships'] = site.collections['memberships'].docs.find_all { |m| m['person_id'] == person['id'] }
  end

  posts = parliament['posts'].map do |p|
    layout = Jekyll::Utils.slugify(p['label']).gsub('-', '_')
    if site.layouts.key?(layout)
      p['layout'] = layout
    else
      Jekyll.logger.warn "Couldn't find layout: #{layout} for post #{p['id']}"
      p['layout'] = 'default'
    end
    p['title'] = p['label']
    p
  end

  term_9_posts = posts.map do |p|
    p.merge(
      'memberships' => site.collections['memberships'].docs.find_all do |m|
        m['post_id'] == p['id'] && m['legislative_period_id'] == 'term/9'
      end
    )
  end
  term_10_posts = posts.map do |p|
    p.merge(
      'memberships' => site.collections['memberships'].docs.find_all do |m|
        m['post_id'] == p['id'] && m['legislative_period_id'] == 'term/10'
      end
    )
  end

  popolo.create_jekyll_collections(
    term_9_posts: term_9_posts,
    term_10_posts: term_10_posts,
  )

  %w(term_9_posts term_10_posts).each do |collection|
    site.collections[collection].docs.each do |post|
      post.data['memberships'].each { |m| m.data['post'] = post }
    end
  end

  site.collections['term_9_posts'].docs.each do |post|
    post.data['next_term_posts'] = site.collections['term_10_posts'].docs.find { |d| d['id'] == post['id'] }
  end

  site.collections['term_10_posts'].docs.each do |post|
    post.data['previous_term_posts'] = site.collections['term_9_posts'].docs.find { |d| d['id'] == post['id'] }
  end

  ocd_ids = CSV.parse(open('https://github.com/theyworkforyou/uganda_ocd_ids/raw/master/identifiers/country-ug.csv').read, headers: true, header_converters: :symbol)
  ocd_mapping = Hash[ocd_ids.map { |id| [id[:id], id[:name]] }]
  # Group current memberships by district
  memberships, memberships_without_area = site.collections['memberships'].docs.partition do |membership|
    membership['area_id']
  end
  memberships_by_district = memberships.group_by do |d|
    d['area_id'].split('/').slice_after(/^district\:/).first.join('/')
  end
  districts = memberships_by_district.map do |id, memberships|
    {
      'id' => id.sub('ocd-division/country:ug/', '').gsub(/\w+\:/, ''),
      'title' => ocd_mapping[id] || id,
      'layout' => 'districts',
      'name' => ocd_mapping[id] || id,
      'memberships' => memberships
    }
  end
  popolo.create_jekyll_collections(districts: districts.sort_by { |d| d['name'] })
end
