require "rails"

require "acube"

module ACube
  class Engine < Rails::Engine
    isolate_namespace ACube
    config.eager_load_namespaces << ACube

    config.autoload_once_paths = %W(
      #{root}/app/models
    )

    initializer "acube.attribute" do
      ActiveSupport.on_load(:active_record) do
        include ACube::Attribute
      end
    end
  end
end