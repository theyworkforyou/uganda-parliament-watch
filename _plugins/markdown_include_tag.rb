# Jekyll tag to include Markdown text from _includes directory preprocessing with Liquid.
# Usage:
#   {% markdown <filename> %}
#
# @see http://wolfslittlestore.be/2013/10/rendering-markdown-in-jekyll/
module Jekyll
  class MarkdownTag < Liquid::Tag
    def initialize(tag_name, filename, tokens)
      super
      @filename = filename.strip
    end

    def render(context)
      site = context.registers[:site]
      path = File.join(Dir.pwd, '_includes', @filename)
      content = File.read(path)
      tmpl = site.liquid_renderer.file(path).parse(content).render!(site.site_payload)
      site.converters.find { |c| c.matches(File.extname(path)) }.convert(tmpl)
    end
  end
end

Liquid::Template.register_tag('markdown', Jekyll::MarkdownTag)
