require 'spec'

require 'rubygems'
spec = Gem::Specification.load(File.expand_path('../jekylltask.gemspec', File.dirname(__FILE__)))
spec.dependencies.select { |dep| dep.type == :runtime }.each { |dep| gem dep.name, (dep.respond_to?(:requirement) ? dep.requirement.to_s : dep.version_requirements.to_s) }

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'jekylltask'
