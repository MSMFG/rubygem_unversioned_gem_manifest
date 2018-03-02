class << $LOAD_PATH
  def merge!(other)
    replace(self | other)
  end
end

$LOAD_PATH.merge! [File.expand_path('../lib', __FILE__)]

Gem::Specification.new do |spec|
  raise 'RubyGems 2.0 or newer is required.' unless spec.respond_to?(:metadata)
  spec.name = 'unversioned_gem_manifest'
  spec.version = '1.0.0'
  spec.authors = ['Andrew Smith']
  spec.email = ['andrew.smith at moneysupermarket.com']

  spec.summary = 'Create manifest of gem installs with no version requirement'
  spec.description = 'Record to a structured manifest file a list of gems that'\
                     ' have installed without specifying some form of version '\
                     'requirement'
  spec.homepage = 'https://github.com/MSMFG/rubygem_unversioned_gem_manifest'
  spec.license = 'Apache-2.0'
  spec.files = `git ls-files -z`.split("\x0")
  spec.add_runtime_dependency 'gem_pre_unversioned_install', '~> 1'
end
