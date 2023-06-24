require "active_support"
require "active_support/rails"

require "acube/version"

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
end
