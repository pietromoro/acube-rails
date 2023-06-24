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

  autoload :Attribute
end

loader = Zeitwerk::Loader.for_gem
loader.inflector.inflect(
  "acube" => "ACube",
  "acube_api" => "ACubeAPI"
)
loader.setup