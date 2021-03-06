require_relative 'lib/image_quality_check/version'

Gem::Specification.new do |spec|
  spec.name          = "image_quality_check"
  spec.version       = ImageQualityCheck::VERSION
  spec.authors       = ["Stefan Wienert"]
  spec.email         = ["info@stefanwienert.de"]

  spec.summary       = %q{Thin gem wrapper that uses imagemagick and python-opencv to help determine image quality.}
  spec.description   = %q{Thin gem wrapper that uses imagemagick and python-opencv to help determine image quality of e.g. user portraits.}
  spec.homepage      = "https://github.com/pludoni/ruby-image-quality-check"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.add_runtime_dependency "i18n"
end
