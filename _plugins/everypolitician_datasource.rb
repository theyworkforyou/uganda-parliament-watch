# Configures the jekyll-everypolitician plugin to use the url in DATASOURCE
Jekyll::Hooks.register :site, :after_reset do |site|
  datasource = File.read('EVERYPOLITICIAN_DATASOURCE').chomp
  site.config['everypolitician'] ||= { 'sources' => [datasource] }
end
