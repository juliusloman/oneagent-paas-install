require 'serverspec'

# Required by serverspec
set :backend, :exec

ENV['HOME'] = '/tmp/kitchen/data'
require ENV['HOME'] + '/test/dynatrace/defaults.rb'
require ENV['HOME'] + '/test/dynatrace/util.rb'

# Test installer: all technologies, 64-bit, into /tmp)
opts = {
  DT_AGENT_BASE_URL:   Dynatrace::Defaults::DT_AGENT_BASE_URL,
  DT_API_TOKEN:        Dynatrace::Defaults::DT_API_TOKEN,
  DT_AGENT_FOR:        'all',
  DT_AGENT_BITNESS:    '64',
  DT_AGENT_PREFIX_DIR: '/tmp'
}

describe command(Dynatrace::Util::parse_cmd('~/paas-install.sh', opts)) do
  its(:stdout) { should match /Installing to \/tmp.*Unpacking complete./m }
  its(:stdout) { should match Regexp.new("Connecting to #{Dynatrace::Defaults::DT_AGENT_BASE_URL}") }
  its(:exit_status) { should eq 0 }
end

describe file('/tmp/dynatrace/oneagent/dynatrace-env.sh') do
  it { should be_file }
  its(:content) { should include 'export DT_TENANT=' + Dynatrace::Defaults::DT_TENANT }
  its(:content) { should include 'export DT_TENANTTOKEN=' + Dynatrace::Defaults::DT_TENANTTOKEN }
  its(:content) { should match /export DT_CONNECTION_POINT=".+"/ }
end

describe file('/tmp/dynatrace/oneagent/dynatrace-agent32.sh') do
  it { should_not exist }
end

describe file('/tmp/dynatrace/oneagent/dynatrace-agent64.sh') do
  it { should be_file }
  it { should be_executable }
end

describe file('/tmp/dynatrace-oneagent.sh') do
  it { should_not exist }
end