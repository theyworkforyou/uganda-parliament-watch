module Jekyll
  class LinksJsonpPage < Jekyll::Page
    def initialize(site, base, dir, name)
      @site = site
      @base = base
      @dir = dir
      @name = name

      process(@name)

      pages_with_titles = site.pages.find_all { |p| p.data['title'] && p.data['title'] != '' }
      pages_to_link = pages_with_titles.sort_by { |p| p.data['title'] }
      posts_to_link = site.posts.docs.sort_by { |p| p.data['title'] }

      links = (pages_to_link + posts_to_link).map do |p|
        {
          text: p.data['title'],
          href: p.url
        }
      end

      site.collections.each do |_name, collection|
        links += collection.docs.map do |doc|
          {
            text: doc.data['title'],
            href: doc.url
          }
        end
      end

      self.data = {}
      self.content = "callback(#{JSON.pretty_generate(links)})"

      Jekyll::Hooks.trigger :pages, :post_init, self
    end
  end

  class ProseIoLinks < Jekyll::Generator
    def generate(site)
      site.pages << LinksJsonpPage.new(site, site.source, '', 'links.jsonp')
    end
  end
end
