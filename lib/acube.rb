require "active_support"
require "active_support/rails"

require "acube/version"
require "acube/engine"

require "zeitwerk"

module ACube
  extend ActiveSupport::Autoload

  mattr_accessor :invoice_endpoint
  mattr_accessor :common_endpoint

  mattr_accessor :invoice_base_class, default: "ApplicationRecord"
  
  mattr_accessor :webhook_base_class, default: "ApplicationController"
  mattr_accessor :webhook_endpoint, default: "/acube-api/webhook"
  mattr_accessor :webhook_secret_key
  mattr_accessor :webhook_secret

  mattr_accessor :webhook_signature_key
  mattr_accessor :webhook_signature_gpg
  
  mattr_accessor :auth_token_cache_key, default: "__acube__auth__token"

  mattr_accessor :progressive_string, default: -> (number) { "#{number}" }

  autoload :Attribute
  autoload :SignatureChecker

  module Endpoint
    extend ActiveSupport::Autoload

    autoload :CommonBase
    autoload :ItApiBase

    autoload :Auth
    autoload :Invoices
  end

  module Schema
    module Header
      extend ActiveSupport::Autoload

      autoload :Supplier
      autoload :Customer
    end
  end

  module Consumer
    autoload :Model, "acube/concerns/consumer"
  end

  module Supplier
    autoload :Model, "acube/concerns/supplier"
  end
end

loader = Zeitwerk::Loader.for_gem
loader.inflector.inflect(
  "acube" => "ACube",
  "acube_api" => "ACubeAPI"
)
loader.setup