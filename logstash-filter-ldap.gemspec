Gem::Specification.new do |s|
  s.name          = 'logstash-filter-ldap'
  s.version       = '0.2.4'
  s.licenses      = ['Apache License (2.0)']
  s.summary       = 'Logstash filter to get LDAP or LDAPs informations.'
  s.description   = 'This is a Logstash''s filter plugin to fetch LDAP informations. Do not use it standalone.'
  s.homepage      = 'https://github.com/Transrian/logstash-filter-ldap'
  s.authors       = ['Valentin Bourdier']
  s.email         = 'valentin.bourdier@mail.com'
  s.require_paths = ['lib']

  # Files
  s.files = Dir['lib/**/*','spec/**/*','vendor/**/*','*.gemspec','*.md','CONTRIBUTORS','Gemfile','LICENSE','NOTICE.TXT']
   # Tests
  s.test_files = s.files.grep(%r{^(test|spec|features)/})

  # Special flag to let us know this is actually a logstash plugin
  s.metadata = { "logstash_plugin" => "true", "logstash_group" => "filter" }

  # Gem dependencies
  s.add_runtime_dependency "logstash-core-plugin-api", ">= 1.60", "<= 2.99"
  s.add_runtime_dependency 'net-ldap', '~> 0.16.2'
  s.add_runtime_dependency 'lru_redux', "~> 1.1.0"
  s.add_runtime_dependency 'rufus-scheduler', ">= 3.0.9"

  s.add_development_dependency 'logstash-devutils'
end
