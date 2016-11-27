require 'ddreleaser'

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
end
