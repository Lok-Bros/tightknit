# frozen_string_literal: true

require "bundler/gem_tasks"
require "minitest/test_task"

Minitest::TestTask.create

require "standard/rake"

begin
  require "yard"
  YARD::Rake::YardocTask.new do |t|
    t.files = ["lib/**/*.rb"]
    t.options = ["--output-dir", "doc/yard"]
    t.stats_options = ["--list-undoc"]
  end

  desc "Generate YARD documentation and open in browser"
  task :yard_open do
    Rake::Task["yard"].invoke
    `open doc/yard/index.html`
  end
rescue LoadError
  desc "Generate YARD documentation (YARD not available)"
  task :yard do
    abort "YARD is not available. Run `gem install yard` to install it."
  end
end

task default: %i[test standard]
