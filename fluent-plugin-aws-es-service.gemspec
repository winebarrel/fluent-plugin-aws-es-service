# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = 'fluent-plugin-aws-es-service'
  spec.version       = '0.1.0'
  spec.authors       = ['winebarrel']
  spec.email         = ['sgwr_dts@yahoo.co.jp']

  spec.summary       = %q{Fluentd output plugin to send to Amazon ES Service.}
  spec.description   = %q{Fluentd output plugin to send to Amazon ES Service.}
  spec.homepage      = 'https://github.com/winebarrel/fluent-plugin-aws-es-service'
  spec.license       = 'Apache-2.0'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'fluent-plugin-elasticsearch', '~> 1.9'
  spec.add_dependency 'faraday_middleware-aws-sigv4'
  spec.add_dependency 'aws-sdk-core', '~> 3.3'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
