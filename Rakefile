require 'cookstyle'
require 'rake-foodcritic'
require 'rubocop/rake_task'

task default: [:style, 'chef:foodcritic']

RuboCop::RakeTask.new(:style) do |task|
  task.options << '--display-cop-names'
end
