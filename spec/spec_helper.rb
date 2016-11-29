require 'released'

require 'webmock/rspec'
require 'rspec/its'

RSpec.configure do |c|
  c.around(:each, stdio: true) do |example|
    orig_stdout = $stdout
    orig_stderr = $stderr

    $stdout = StringIO.new
    $stderr = StringIO.new

    example.run

    $stdout = orig_stdout
    $stderr = orig_stderr
  end

  c.around(:each) do |example|
    Dir.mktmpdir('released-specs') do |dir|
      FileUtils.cd(dir) do
        example.run
      end
    end
  end
end
