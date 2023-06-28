# frozen_string_literal: true

require "pathname"

module ACube
  module Generators
    class InstallGenerator < ::Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)

      def create_migrations
        rails_command "railties:install:migrations FROM=active_storage,a_cube", inline: true
      end
    end
  end
end