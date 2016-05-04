require 'open-uri'

Jekyll::Popolo.register(:senate, open(File.read('EVERYPOLITICIAN_DATASOURCE').chomp).read)

Jekyll::Popolo.process(:senate) do |site, popolo|
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
