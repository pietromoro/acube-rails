# frozen_string_literal: true

module ACube
  class Record < ActiveRecord::Base # :nodoc:
    self.abstract_class = true
  end
end

ActiveSupport.run_load_hooks :acube_record, ACube::Record