require 'open-uri'

Jekyll::Popolo.register(:parliament, open(File.read('EVERYPOLITICIAN_DATASOURCE').chomp).read)

Jekyll::Popolo.process(:parliament) do |site, popolo|
  popolo['memberships'].each do |membership|
    membership['person'] = popolo['persons'].find { |p| p['id'] == membership['person_id'] }
    membership['party'] = popolo['organizations'].find { |o| o['id'] == membership['on_behalf_of_id'] }
    membership['term'] = popolo['events'].find { |e| e['id'] == membership['legislative_period_id'] }
    membership['post'] = popolo['posts'].find { |p| p['id'] == membership['post_id'] }
    membership['area'] = popolo['areas'].find { |a| a['id'] == membership['area_id'] }
  end
  posts = popolo['posts'].map do |p|
    layout = Jekyll::Utils.slugify(p['label']).gsub('-', '_')
    if site.layouts.key?(layout)
      p['layout'] = layout
    else
      Jekyll.logger.warn "Couldn't find layout: #{layout} for post #{p}"
      p['layout'] = 'default'
    end
    p['title'] = p['label']
    p
  end

  term_9_posts = posts.map do |p|
    p['memberships'] = popolo['memberships'].find_all do |m|
      m['post_id'] == p['id'] && m['legislative_period_id'] == 'term/9'
    end
    p
  end
  term_10_posts = posts.map do |p|
    p['memberships'] = popolo['memberships'].find_all do |m|
      m['post_id'] == p['id'] && m['legislative_period_id'] == 'term/10'
    end
    p
  end

  {
    term_9_posts: term_9_posts,
    term_10_posts: term_10_posts,
  }
end
