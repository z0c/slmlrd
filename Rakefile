require 'rake/testtask'
Dir["#{File.dirname(__FILE__)}/lib/tasks/*.rake"].sort.each do |ext|
  load ext
end

Rake::TestTask.new do |t|
  t.libs << 'tests'
  t.test_files = FileList['tests/*.rb']
  t.verbose = true
  t.warning = false
end
