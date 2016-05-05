require 'open-uri'

Jekyll::Popolo.register_popolo_file(:parliament, open(File.read('EVERYPOLITICIAN_DATASOURCE').chomp).read)

Jekyll::Popolo.process do |site, popolo|
  parliament = popolo.files[:parliament]
  people = parliament['persons'].map do |person|
    person['layout'] = 'people'
    person['title'] = person['name']
    if person['image']
      person['image'] = "https://theyworkforyou.github.io/uganda-images/Parliament/#{person['id']}.jpeg"
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
end
