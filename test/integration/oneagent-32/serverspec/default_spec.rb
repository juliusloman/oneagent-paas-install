require 'serverspec'

# Required by serverspec
set :backend, :exec

ENV['HOME'] = '/tmp/kitchen/data'
require ENV['HOME'] + '/test/dynatrace/defaults.rb'
require ENV['HOME'] + '/test/dynatrace/util.rb'

# Test installer: all technologies, 32-bit, into /tmp)
opts = {
  DT_CLUSTER_HOST:        Dynatrace::Defaults::DT_CLUSTER_HOST,
  DT_API_TOKEN:           Dynatrace::Defaults::DT_API_TOKEN,
  DT_ONEAGENT_FOR:        'all',
  DT_ONEAGENT_BITNESS:    '32',
  DT_ONEAGENT_PREFIX_DIR: '/tmp'
}

describe command(Dynatrace::Util::parse_cmd('~/dynatrace-oneagent-paas.sh', opts)) do
  its(:stdout) { should match /Installing to \/tmp.*Unpacking complete./m }
  its(:stdout) { should contain "Connecting to https://#{Dynatrace::Defaults::DT_CLUSTER_HOST}" }
  its(:exit_status) { should eq 0 }
end

describe file('/tmp/dynatrace/oneagent/dynatrace-env.sh') do
  it { should be_file }
  its(:content) { should contain "export DT_TENANT=#{Dynatrace::Defaults::DT_TENANT}" }
  its(:content) { should contain "export DT_TENANTTOKEN=#{Dynatrace::Defaults::DT_TENANT_TOKEN}" }
  its(:content) { should match /export DT_CONNECTION_POINT=".+"/ }
end

describe file('/tmp/dynatrace/oneagent/dynatrace-agent32.sh') do
  it { should be_file }
  it { should be_executable }
end

describe file('/tmp/dynatrace/oneagent/dynatrace-agent64.sh') do
  it { should_not exist }
end

describe file('/tmp/dynatrace-oneagent.sh') do
  it { should_not exist }
end