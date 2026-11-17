# frozen_string_literal: true

require File.expand_path('lib/prawn/widgets/version', __dir__)

Gem::Specification.new do |spec|
  spec.required_ruby_version = '>= 4.0'

  spec.name        = 'prawn-widget'
  spec.version     = Prawn::Widgets::VERSION::STRING
  spec.summary     = 'The `view_component` syntax, but implemented for Prawn.'
  spec.description = "#{spec.summary} So you can create reusable widgets."
  spec.authors     = ['halo']
  spec.homepage    = 'https://github.com/halo/prawn-widget'

  spec.files         = Dir['{lib}/**/*', 'README*', 'CHANGELOG*', 'LICENSE.md'] & `git ls-files -z`.split("\0")
  spec.license       = 'MIT'
  spec.require_paths = ['lib']

  spec.add_dependency 'activesupport'
  spec.add_dependency 'calls'
  spec.metadata['rubygems_mfa_required'] = 'true'
end
