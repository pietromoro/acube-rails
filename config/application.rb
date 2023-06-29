Rails.autoloaders.each do |autoloader|
  autoloader.inflector.inflect(
    'acube' => 'ACube'
  )
end

ActiveSupport::Inflector.inflections(:en) do |inflect|
  inflect.acronym "ACube"
end
