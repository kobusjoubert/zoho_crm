# frozen_string_literal: true

require_relative 'lib/zoho_crm/version'

Gem::Specification.new do |spec|
  spec.name = 'active_call-zoho_crm'
  spec.version = ZohoCrm::VERSION
  spec.authors = ['Kobus Joubert']
  spec.email = ['kobus@translate3d.com']

  spec.summary = 'Zoho CRM'
  spec.description = 'Zoho CRM exposes the Zoho CRM API endpoints through service objects.'
  spec.homepage = 'https://github.com/kobusjoubert/zoho_crm'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.1.0'

  spec.metadata['allowed_push_host'] = 'https://rubygems.org'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/kobusjoubert/zoho_crm'
  spec.metadata['changelog_uri'] = 'https://github.com/kobusjoubert/zoho_crm/blob/main/CHANGELOG.md'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'active_call-api', '~> 0.1'
end
