require 'serverspec'

# Required by serverspec
set :backend, :exec

ENV['HOME'] = '/tmp/kitchen/data'
require ENV['HOME'] + '/test/dynatrace/defaults.rb'
require ENV['HOME'] + '/test/dynatrace/util.rb'

# Test installer with arguments -h and --help
describe command('~/dynatrace-oneagent-paas.sh -h') do
  its(:stdout) { should contain 'Usage:' }
  its(:exit_status) { should eq 0 }
end

describe command('~/dynatrace-oneagent-paas.sh --help') do
  its(:stdout) { should contain 'Usage:' }
  its(:exit_status) { should eq 0 }
end

# Test installer with insufficient arguments
describe command('~/dynatrace-oneagent-paas.sh') do
  its(:stdout) { should contain 'Usage:' }
  its(:exit_status) { should eq 1 }
end

opts = { DT_TENANT: nil }
describe command(Dynatrace::Util::parse_cmd('~/dynatrace-oneagent-paas.sh', opts)) do
  its(:stdout) { should contain 'Usage:' }
  its(:exit_status) { should eq 1 }
end

opts = { DT_API_TOKEN: nil }
describe command(Dynatrace::Util::parse_cmd('~/dynatrace-oneagent-paas.sh', opts)) do
  its(:stdout) { should contain 'Usage:' }
  its(:exit_status) { should eq 1 }
end

opts = { DT_TENANT: nil, DT_AGENT_BASE_URL: nil }
describe command(Dynatrace::Util::parse_cmd('~/dynatrace-oneagent-paas.sh', opts)) do
  its(:stdout) { should contain 'Usage:' }
  its(:exit_status) { should eq 1 }
end

# Test installer with valid DT_TENANT and invalid DT_API_TOKEN
opts = { DT_TENANT: '12345678', DT_API_TOKEN: nil }
describe command(Dynatrace::Util::parse_cmd('~/dynatrace-oneagent-paas.sh', opts)) do
  its(:stderr) { should eq "dynatrace-oneagent-paas.sh: failed to validate DT_API_TOKEN: \n" }
  its(:exit_status) { should eq 1 }
end

opts = { DT_TENANT: '12345678', DT_API_TOKEN: 'abcdefghijklmnopqrstuvwxyz$' }
describe command(Dynatrace::Util::parse_cmd('~/dynatrace-oneagent-paas.sh', opts)) do
  its(:stderr) { should eq "dynatrace-oneagent-paas.sh: failed to validate DT_API_TOKEN: abcdefghijklmnopqrstuvwxyz$\n" }
  its(:exit_status) { should eq 1 }
end

# Test installer with invalid DT_TENANT and valid DT_API_TOKEN
opts = { DT_TENANT: nil, DT_API_TOKEN: 'abcdefghijklmnopqrstuvwxyz' }
describe command(Dynatrace::Util::parse_cmd('~/dynatrace-oneagent-paas.sh', opts)) do
  its(:stderr) { should eq "dynatrace-oneagent-paas.sh: failed to validate DT_TENANT: \n" }
  its(:exit_status) { should eq 1 }
end

opts = { DT_TENANT: '1234567$', DT_API_TOKEN: 'abcdefghijklmnopqrstuvwxyz' }
describe command(Dynatrace::Util::parse_cmd('~/dynatrace-oneagent-paas.sh', opts)) do
  its(:stderr) { should eq "dynatrace-oneagent-paas.sh: failed to validate DT_TENANT: 1234567$\n" }
  its(:exit_status) { should eq 1 }
end

opts = { DT_TENANT: '1234567', DT_API_TOKEN: 'abcdefghijklmnopqrstuvwxyz' }
describe command(Dynatrace::Util::parse_cmd('~/dynatrace-oneagent-paas.sh', opts)) do
  its(:stderr) { should eq "dynatrace-oneagent-paas.sh: failed to validate DT_TENANT: 1234567\n" }
  its(:exit_status) { should eq 1 }
end

opts = { DT_TENANT: '123456789', DT_API_TOKEN: 'abcdefghijklmnopqrstuvwxyz' }
describe command(Dynatrace::Util::parse_cmd('~/dynatrace-oneagent-paas.sh', opts)) do
  its(:stderr) { should eq "dynatrace-oneagent-paas.sh: failed to validate DT_TENANT: 123456789\n" }
  its(:exit_status) { should eq 1 }
end

# Test installer with invalid DT_TENANT and invalid DT_API_TOKEN
opts = { DT_TENANT: nil, DT_API_TOKEN: nil }
describe command(Dynatrace::Util::parse_cmd('~/dynatrace-oneagent-paas.sh', opts)) do
  its(:stderr) { should eq "dynatrace-oneagent-paas.sh: failed to validate DT_TENANT: \n" }
  its(:exit_status) { should eq 1 }
end

opts = { DT_TENANT: '1234567$', DT_API_TOKEN: 'abcdefghijklmnopqrstuvwxy$' }
describe command(Dynatrace::Util::parse_cmd('~/dynatrace-oneagent-paas.sh', opts)) do
  its(:stderr) { should eq "dynatrace-oneagent-paas.sh: failed to validate DT_TENANT: 1234567$\n" }
  its(:exit_status) { should eq 1 }
end

# Test installer with invalid DT_AGENT_BASE_URL and valid DT_API_TOKEN
opts = { DT_AGENT_BASE_URL: nil, DT_API_TOKEN: 'abcdefghijklmnopqrstuvwxyz' }
describe command(Dynatrace::Util::parse_cmd('~/dynatrace-oneagent-paas.sh', opts)) do
  its(:stderr) { should eq "dynatrace-oneagent-paas.sh: failed to validate DT_AGENT_BASE_URL: \n" }
  its(:exit_status) { should eq 1 }
end

opts = { DT_AGENT_BASE_URL: '123abc', DT_API_TOKEN: 'abcdefghijklmnopqrstuvwxyz' }
describe command(Dynatrace::Util::parse_cmd('~/dynatrace-oneagent-paas.sh', opts)) do
  its(:stderr) { should eq "dynatrace-oneagent-paas.sh: failed to validate DT_AGENT_BASE_URL: 123abc\n" }
  its(:exit_status) { should eq 1 }
end

opts = { DT_AGENT_BASE_URL: 'http://12345678.live.dynatrace.com', DT_API_TOKEN: 'abcdefghijklmnopqrstuvwxyz' }
describe command(Dynatrace::Util::parse_cmd('~/dynatrace-oneagent-paas.sh', opts)) do
  its(:stderr) { should eq "dynatrace-oneagent-paas.sh: failed to validate DT_AGENT_BASE_URL: http://12345678.live.dynatrace.com\n" }
  its(:exit_status) { should eq 1 }
end

# Test installer with invalid DT_AGENT_BITNESS
opts = { DT_AGENT_BITNESS: '128', DT_TENANT: '12345678', DT_API_TOKEN: 'abcdefghijklmnopqrstuvwxyz' }
describe command(Dynatrace::Util::parse_cmd('~/dynatrace-oneagent-paas.sh', opts)) do
  its(:stderr) { should eq "dynatrace-oneagent-paas.sh: failed to validate DT_AGENT_BITNESS: 128\n" }
  its(:exit_status) { should eq 1 }
end

opts = { DT_AGENT_BITNESS: 'sixty-four', DT_TENANT: '12345678', DT_API_TOKEN: 'abcdefghijklmnopqrstuvwxyz' }
describe command(Dynatrace::Util::parse_cmd('~/dynatrace-oneagent-paas.sh', opts)) do
  its(:stderr) { should eq "dynatrace-oneagent-paas.sh: failed to validate DT_AGENT_BITNESS: sixty-four\n" }
  its(:exit_status) { should eq 1 }
end

# Test installer with invalid DT_AGENT_FOR
opts = { DT_AGENT_FOR: 'everything-under-the-sun', DT_TENANT: '12345678', DT_API_TOKEN: 'abcdefghijklmnopqrstuvwxyz' }
describe command(Dynatrace::Util::parse_cmd('~/dynatrace-oneagent-paas.sh', opts)) do
  its(:stderr) { should eq "dynatrace-oneagent-paas.sh: failed to validate DT_AGENT_FOR: everything-under-the-sun\n" }
  its(:exit_status) { should eq 1 }
end

# Test installer with invalid DT_AGENT_PREFIX_DIR
opts = { DT_AGENT_PREFIX_DIR: 'a', DT_TENANT: '12345678', DT_API_TOKEN: 'abcdefghijklmnopqrstuvwxyz' }
describe command(Dynatrace::Util::parse_cmd('~/dynatrace-oneagent-paas.sh', opts)) do
  its(:stderr) { should eq "dynatrace-oneagent-paas.sh: failed to validate DT_AGENT_PREFIX_DIR: a\n" }
  its(:exit_status) { should eq 1 }
end

opts = { DT_AGENT_PREFIX_DIR: 'a/b', DT_TENANT: '12345678', DT_API_TOKEN: 'abcdefghijklmnopqrstuvwxyz' }
describe command(Dynatrace::Util::parse_cmd('~/dynatrace-oneagent-paas.sh', opts)) do
  its(:stderr) { should eq "dynatrace-oneagent-paas.sh: failed to validate DT_AGENT_PREFIX_DIR: a/b\n" }
  its(:exit_status) { should eq 1 }
end

opts = { DT_AGENT_PREFIX_DIR: 'a//b', DT_TENANT: '12345678', DT_API_TOKEN: 'abcdefghijklmnopqrstuvwxyz' }
describe command(Dynatrace::Util::parse_cmd('~/dynatrace-oneagent-paas.sh', opts)) do
  its(:stderr) { should eq "dynatrace-oneagent-paas.sh: failed to validate DT_AGENT_PREFIX_DIR: a//b\n" }
  its(:exit_status) { should eq 1 }
end

opts = { DT_AGENT_PREFIX_DIR: 'here', DT_TENANT: '12345678', DT_API_TOKEN: 'abcdefghijklmnopqrstuvwxyz' }
describe command(Dynatrace::Util::parse_cmd('~/dynatrace-oneagent-paas.sh', opts)) do
  its(:stderr) { should eq "dynatrace-oneagent-paas.sh: failed to validate DT_AGENT_PREFIX_DIR: here\n" }
  its(:exit_status) { should eq 1 }
end

# Test installer with non-existent DT_AGENT_BASE_URL
opts = { DT_AGENT_BASE_URL: 'https://my-tenant.my-dynatrace-cluster.com', DT_API_TOKEN: 'abcdefghijklmnopqrstuvwxyz' }
describe command(Dynatrace::Util::parse_cmd('~/dynatrace-oneagent-paas.sh', opts)) do
  its(:stdout) { should contain "Connecting to https://my-tenant.my-dynatrace-cluster.com" }
  its(:stderr) { should match /could not resolve host/i }
  its(:exit_status) { should_not eq 0 }
end

# Test installer with non-existent DT_TENANT
opts = { DT_TENANT: '12345678', DT_API_TOKEN: 'abcdefghijklmnopqrstuvwxyz' }
describe command(Dynatrace::Util::parse_cmd('~/dynatrace-oneagent-paas.sh', opts)) do
  its(:stdout) { should contain "Connecting to https://12345678.live.dynatrace.com/" }
  its(:stderr) { should match /failed to resolve tenant <12345678>/i }
  its(:stderr) { should contain "404" }
  its(:exit_status) { should_not eq 0 }
end

# Test installer with invalid DT_API_TOKEN
opts = { DT_AGENT_BASE_URL: Dynatrace::Defaults::DT_AGENT_BASE_URL, DT_API_TOKEN: 'abcdefghijklmnopqrstuvwxyz' }
describe command(Dynatrace::Util::parse_cmd('~/dynatrace-oneagent-paas.sh', opts)) do
  its(:stdout) { should contain "Connecting to #{Dynatrace::Defaults::DT_AGENT_BASE_URL}" }
  its(:stderr) { should match /token authentication failed/i }
  its(:stderr) { should contain "401" }
  its(:exit_status) { should_not eq 0 }
end

# Test installer: defaults
opts = { DT_AGENT_BASE_URL: Dynatrace::Defaults::DT_AGENT_BASE_URL, DT_API_TOKEN: Dynatrace::Defaults::DT_API_TOKEN }
describe command(Dynatrace::Util::parse_cmd('~/dynatrace-oneagent-paas.sh', opts)) do
  its(:stdout) { should match /Installing to \/var\/lib.*Unpacking complete./m }
  its(:stdout) { should contain "Connecting to #{Dynatrace::Defaults::DT_AGENT_BASE_URL}" }
  its(:exit_status) { should eq 0 }
end

describe file('/var/lib/dynatrace/oneagent/dynatrace-env.sh') do
  it { should be_file }
  its(:content) { should contain 'export DT_TENANT=' + Dynatrace::Defaults::DT_TENANT }
  its(:content) { should contain 'export DT_TENANTTOKEN=' + Dynatrace::Defaults::DT_TENANTTOKEN }
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