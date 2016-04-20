module Jekyll
  class ImageCache < Jekyll::Generator
    def generate(site)
      site.collections['people'].docs.each do |person|
        if person.data['image']
          person.data['image'] = "https://theyworkforyou.github.io/uganda-images/Parliament/#{person.data['id']}.jpeg"
        end
      end
    end
  end
end
