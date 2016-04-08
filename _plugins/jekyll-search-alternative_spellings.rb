Jekyll::Search::AlternativeSpellings.register :people do |person|
  person.data['other_names'].map { |on| on['name'] } if person.data.key?('other_names')
end
