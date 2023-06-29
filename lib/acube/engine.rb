require "rails"
require "active_record/railtie"
require "action_controller/railtie"
require "active_storage/engine"

require "acube"

module ACube
  class Engine < ::Rails::Engine
    isolate_namespace ACube
    config.eager_load_namespaces << ACube

    config.autoload_paths = %W(
      #{root}/app/models
    )

    initializer "acube.attribute" do
      ActiveSupport.on_load(:active_record) do
        include ACube::Attribute
      end
    end
  end
end