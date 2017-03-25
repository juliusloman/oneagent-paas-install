require 'serverspec'

# Required by serverspec
set :backend, :exec

ENV['HOME'] = '/tmp/kitchen/data'

DT_CLUSTER = 'dev.dynatracelabs.com'
DT_TENANT = 'ryx70518'
DT_TENANTTOKEN = 'NkM5fd7JG1Hzmmoh'
DT_API_TOKEN = 'w89AycHAQByUUfu993UHG'
DT_AGENT_BASE_URL = "https://#{DT_TENANT}.#{DT_CLUSTER}"

def parse_cmd(cmd, opts)
  result = ''

  unless opts.empty?
    opts.each do | key, value |
      result << key.to_s + "="

      unless value.nil?
        result << "'" + value.to_s + "'"
      end

      result << ' '
    end
  end

  result << cmd
end

# Test installer with insufficient arguments
describe command('~/paas-install.sh') do
  its(:stdout) { should eq "help...\n" }
  its(:exit_status) { should eq 1 }
end

opts = { DT_TENANT: nil }
describe command(parse_cmd('~/paas-install.sh', opts)) do
  its(:stdout) { should eq "help...\n" }
  its(:exit_status) { should eq 1 }
end

opts = { DT_API_TOKEN: nil }
describe command(parse_cmd('~/paas-install.sh', opts)) do
  its(:stdout) { should eq "help...\n" }
  its(:exit_status) { should eq 1 }
end

opts = { DT_TENANT: nil, DT_AGENT_BASE_URL: nil }
describe command(parse_cmd('~/paas-install.sh', opts)) do
  its(:stdout) { should eq "help...\n" }
  its(:exit_status) { should eq 1 }
end

# Test installer with valid DT_TENANT and invalid DT_API_TOKEN
opts = { DT_TENANT: '12345678', DT_API_TOKEN: nil }
describe command(parse_cmd('~/paas-install.sh', opts)) do
  its(:stderr) { should eq "paas-install.sh: failed to validate DT_API_TOKEN: \n" }
  its(:exit_status) { should eq 1 }
end

opts = { DT_TENANT: '12345678', DT_API_TOKEN: 'abcdefghijklmnopqrstuvwxyz$' }
describe command(parse_cmd('~/paas-install.sh', opts)) do
  its(:stderr) { should eq "paas-install.sh: failed to validate DT_API_TOKEN: abcdefghijklmnopqrstuvwxyz$\n" }
  its(:exit_status) { should eq 1 }
end

# Test installer with invalid DT_TENANT and valid DT_API_TOKEN
opts = { DT_TENANT: nil, DT_API_TOKEN: 'abcdefghijklmnopqrstuvwxyz' }
describe command(parse_cmd('~/paas-install.sh', opts)) do
  its(:stderr) { should eq "paas-install.sh: failed to validate DT_TENANT: \n" }
  its(:exit_status) { should eq 1 }
end

opts = { DT_TENANT: '1234567$', DT_API_TOKEN: 'abcdefghijklmnopqrstuvwxyz' }
describe command(parse_cmd('~/paas-install.sh', opts)) do
  its(:stderr) { should eq "paas-install.sh: failed to validate DT_TENANT: 1234567$\n" }
  its(:exit_status) { should eq 1 }
end

opts = { DT_TENANT: '1234567', DT_API_TOKEN: 'abcdefghijklmnopqrstuvwxyz' }
describe command(parse_cmd('~/paas-install.sh', opts)) do
  its(:stderr) { should eq "paas-install.sh: failed to validate DT_TENANT: 1234567\n" }
  its(:exit_status) { should eq 1 }
end

opts = { DT_TENANT: '123456789', DT_API_TOKEN: 'abcdefghijklmnopqrstuvwxyz' }
describe command(parse_cmd('~/paas-install.sh', opts)) do
  its(:stderr) { should eq "paas-install.sh: failed to validate DT_TENANT: 123456789\n" }
  its(:exit_status) { should eq 1 }
end

# Test installer with invalid DT_TENANT and invalid DT_API_TOKEN
opts = { DT_TENANT: nil, DT_API_TOKEN: nil }
describe command(parse_cmd('~/paas-install.sh', opts)) do
  its(:stderr) { should eq "paas-install.sh: failed to validate DT_TENANT: \n" }
  its(:exit_status) { should eq 1 }
end

opts = { DT_TENANT: '1234567$', DT_API_TOKEN: 'abcdefghijklmnopqrstuvwxy$' }
describe command(parse_cmd('~/paas-install.sh', opts)) do
  its(:stderr) { should eq "paas-install.sh: failed to validate DT_TENANT: 1234567$\n" }
  its(:exit_status) { should eq 1 }
end

# Test installer with invalid DT_AGENT_BASE_URL and valid DT_API_TOKEN
opts = { DT_AGENT_BASE_URL: nil, DT_API_TOKEN: 'abcdefghijklmnopqrstuvwxyz' }
describe command(parse_cmd('~/paas-install.sh', opts)) do
  its(:stderr) { should eq "paas-install.sh: failed to validate DT_AGENT_BASE_URL: \n" }
  its(:exit_status) { should eq 1 }
end

opts = { DT_AGENT_BASE_URL: '123abc', DT_API_TOKEN: 'abcdefghijklmnopqrstuvwxyz' }
describe command(parse_cmd('~/paas-install.sh', opts)) do
  its(:stderr) { should eq "paas-install.sh: failed to validate DT_AGENT_BASE_URL: 123abc\n" }
  its(:exit_status) { should eq 1 }
end

opts = { DT_AGENT_BASE_URL: 'http://12345678.live.dynatrace.com', DT_API_TOKEN: 'abcdefghijklmnopqrstuvwxyz' }
describe command(parse_cmd('~/paas-install.sh', opts)) do
  its(:stderr) { should eq "paas-install.sh: failed to validate DT_AGENT_BASE_URL: http://12345678.live.dynatrace.com\n" }
  its(:exit_status) { should eq 1 }
end

# Test installer with invalid DT_AGENT_BITNESS
opts = { DT_AGENT_BITNESS: '128', DT_TENANT: '12345678', DT_API_TOKEN: 'abcdefghijklmnopqrstuvwxyz' }
describe command(parse_cmd('~/paas-install.sh', opts)) do
  its(:stderr) { should eq "paas-install.sh: failed to validate DT_AGENT_BITNESS: 128\n" }
  its(:exit_status) { should eq 1 }
end

opts = { DT_AGENT_BITNESS: 'sixty-four', DT_TENANT: '12345678', DT_API_TOKEN: 'abcdefghijklmnopqrstuvwxyz' }
describe command(parse_cmd('~/paas-install.sh', opts)) do
  its(:stderr) { should eq "paas-install.sh: failed to validate DT_AGENT_BITNESS: sixty-four\n" }
  its(:exit_status) { should eq 1 }
end

# Test installer with invalid DT_AGENT_FOR
opts = { DT_AGENT_FOR: 'everything-under-the-sun', DT_TENANT: '12345678', DT_API_TOKEN: 'abcdefghijklmnopqrstuvwxyz' }
describe command(parse_cmd('~/paas-install.sh', opts)) do
  its(:stderr) { should eq "paas-install.sh: failed to validate DT_AGENT_FOR: everything-under-the-sun\n" }
  its(:exit_status) { should eq 1 }
end

# Test installer with invalid DT_AGENT_PREFIX_DIR
opts = { DT_AGENT_PREFIX_DIR: 'a', DT_TENANT: '12345678', DT_API_TOKEN: 'abcdefghijklmnopqrstuvwxyz' }
describe command(parse_cmd('~/paas-install.sh', opts)) do
  its(:stderr) { should eq "paas-install.sh: failed to validate DT_AGENT_PREFIX_DIR: a\n" }
  its(:exit_status) { should eq 1 }
end

opts = { DT_AGENT_PREFIX_DIR: 'a/b', DT_TENANT: '12345678', DT_API_TOKEN: 'abcdefghijklmnopqrstuvwxyz' }
describe command(parse_cmd('~/paas-install.sh', opts)) do
  its(:stderr) { should eq "paas-install.sh: failed to validate DT_AGENT_PREFIX_DIR: a/b\n" }
  its(:exit_status) { should eq 1 }
end

opts = { DT_AGENT_PREFIX_DIR: 'a//b', DT_TENANT: '12345678', DT_API_TOKEN: 'abcdefghijklmnopqrstuvwxyz' }
describe command(parse_cmd('~/paas-install.sh', opts)) do
  its(:stderr) { should eq "paas-install.sh: failed to validate DT_AGENT_PREFIX_DIR: a//b\n" }
  its(:exit_status) { should eq 1 }
end

opts = { DT_AGENT_PREFIX_DIR: 'here', DT_TENANT: '12345678', DT_API_TOKEN: 'abcdefghijklmnopqrstuvwxyz' }
describe command(parse_cmd('~/paas-install.sh', opts)) do
  its(:stderr) { should eq "paas-install.sh: failed to validate DT_AGENT_PREFIX_DIR: here\n" }
  its(:exit_status) { should eq 1 }
end

# Test installer with non-existent DT_TENANT
opts = { DT_TENANT: '12345678', DT_API_TOKEN: 'abcdefghijklmnopqrstuvwxyz' }
describe command(parse_cmd('~/paas-install.sh', opts)) do
  its(:stderr) { should match /^Connecting to 12345678.live.dynatrace.com.*404 Not Found\n$/m }
  its(:exit_status) { should eq 1 }
end

# Test installer with non-existent DT_AGENT_BASE_URL
opts = { DT_AGENT_BASE_URL: 'https://my-tenant.my-cluster.com', DT_API_TOKEN: 'abcdefghijklmnopqrstuvwxyz' }
describe command(parse_cmd('~/paas-install.sh', opts)) do
  its(:stderr) { should match /^Connecting to my-tenant.my-cluster.com.*404 Not Found\n$/m }
  its(:exit_status) { should eq 1 }
end

# Test installer with invalid DT_API_TOKEN
opts = { DT_AGENT_BASE_URL: DT_AGENT_BASE_URL, DT_API_TOKEN: 'abcdefghijklmnopqrstuvwxyz' }
describe command(parse_cmd('~/paas-install.sh', opts)) do
  its(:stderr) { should match Regexp.new("^Connecting to #{DT_TENANT}.#{DT_CLUSTER}.*401 Unauthorized\n$", Regexp::MULTILINE) }
  its(:exit_status) { should eq 1 }
end

# Test installer: defaults
opts = { DT_AGENT_BASE_URL: DT_AGENT_BASE_URL, DT_API_TOKEN: DT_API_TOKEN }
describe command(parse_cmd('~/paas-install.sh', opts)) do
  its(:stdout) { should match /Installing to \/var\/lib.*Unpacking complete./m }
  its(:stderr) { should match Regexp.new("Connecting to #{DT_TENANT}.#{DT_CLUSTER}.", Regexp::MULTILINE) }
  its(:exit_status) { should eq 0 }
end

describe file('/var/lib/dynatrace/oneagent/dynatrace-env.sh') do
  it { should be_file }
  its(:content) { should include 'export DT_TENANT=' + DT_TENANT }
  its(:content) { should include 'export DT_TENANTTOKEN=' + DT_TENANTTOKEN }
  its(:content) { should match /export DT_CONNECTION_POINT=".+"/ }
end

describe file('/var/lib/dynatrace/oneagent/dynatrace-agent32.sh') do
  it { should_not exist }
end

describe file('/var/lib/dynatrace/oneagent/dynatrace-agent64.sh') do
  it { should be_file }
  it { should be_executable }
end

describe file('/tmp/dynatrace-oneagent.sh') do
  it { should_not exist }
end