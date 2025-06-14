require "active_support"
require "active_support/rails"

require "acube/version"
require "acube/engine"

require "zeitwerk"

module ACube
  extend ActiveSupport::Autoload

  mattr_accessor :invoice_endpoint
  mattr_accessor :common_endpoint

  mattr_accessor :username
  mattr_accessor :password

  mattr_accessor :invoice_base_class, default: "ApplicationRecord"
  
  mattr_accessor :webhook_base_class, default: "ApplicationController"
  mattr_accessor :webhook_endpoint, default: "/acube-api/webhook"
  mattr_accessor :webhook_secret_key
  mattr_accessor :webhook_secret

  mattr_accessor :webhook_signature_key
  mattr_accessor :webhook_signature_gpg
  
  mattr_accessor :auth_token_cache_key, default: "__acube__auth__token"

  mattr_accessor :invoice_print_theme, default: "standard"
  mattr_accessor :progressive_string, default: -> (number, variant: nil) { "#{number}" }
  mattr_accessor :vat_amount, default: 0.22

  mattr_accessor :transmission_nation_id, default: "IT"
  mattr_accessor :transmission_id_code, default: "10442360961"

  def self.configure
    yield(self)
  end

  autoload :Attribute
  autoload :SignatureChecker
  autoload :Invoicer

  module Endpoint
    extend ActiveSupport::Autoload

    autoload :CommonBase
    autoload :ItApiBase

    autoload :Auth
    autoload :Invoices
  end

  module Schema
    extend ActiveSupport::Autoload

    module Header
      extend ActiveSupport::Autoload

      autoload :Supplier
      autoload :Customer
      autoload :Header
    end

    autoload :Body
    autoload :Document
  end

  module Support
    extend ActiveSupport::Autoload

    autoload :Customer
    autoload :Supplier
    autoload :Transaction
  end
end

loader = Zeitwerk::Loader.for_gem
loader.ignore("#{__dir__}/generators")
loader.inflector.inflect(
  "acube" => "ACube"
)
loader.setup