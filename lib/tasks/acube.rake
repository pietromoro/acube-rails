# frozen_string_literal: true

desc "Copy over the migration"
task "acube:install" do
  Rails::Command.invoke :generate, ["acube:install"]
end