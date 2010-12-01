Gem::Specification.new do |s|
  s.name = %q{tmp8-snailgun}
  s.version = "1.2.0.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Brian Candler", "Sebastian Korfmann", "Thies C. Arntzen"]
  s.date = %q{2010-12-01}
  s.description = %q{Snailgun accelerates the startup of Ruby applications which require large numbers of libraries}
  s.email = ["b.candler@pobox.com", "dev@tmp8.de"]
  s.files = [
    "bin/fautotest", "bin/fconsole", "bin/fcucumber", "bin/frake", "bin/fruby", "bin/snailgun", "bin/snailgun_ruby",
    "lib/snailgun/server.rb", "lib/snailgun/require_timings.rb", "lib/snailgun/client.rb","lib/snailgun/require_preload.rb", "README.markdown", "README-snowleopard", "ruby-1.9.2-p0.patch"
  ]
  s.executables = ["fautotest", "fconsole", "fcucumber", "frake", "fruby", "snailgun", "snailgun_ruby"]
  s.extra_rdoc_files = ["README.markdown"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/tmp8/snailgun}
  s.rdoc_options = ["--inline-source", "--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{snailgun}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Command-line startup accelerator}
  if s.respond_to? :specification_version then
    s.specification_version = 2
  end
end
