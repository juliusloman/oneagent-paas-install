require 'serverspec'

# Required by serverspec
set :backend, :exec

ENV['HOME'] = '/tmp/kitchen/data'
require ENV['HOME'] + '/test/dynatrace/defaults.rb'
require ENV['HOME'] + '/test/dynatrace/oneagent.rb'
require ENV['HOME'] + '/test/dynatrace/util.rb'

# Test installer: Java, 64-bit, into /tmp)
opts = {
  DT_CLUSTER_HOST:        Dynatrace::Defaults::DT_CLUSTER_HOST,
  DT_API_TOKEN:           Dynatrace::Defaults::DT_API_TOKEN,
  DT_ONEAGENT_FOR:        'java',
  DT_ONEAGENT_BITNESS:    '64',
  DT_ONEAGENT_PREFIX_DIR: '/tmp'
}

describe command(Dynatrace::Util::parse_cmd('~/dynatrace-oneagent-paas.sh', opts)) do
  its(:exit_status) { should eq 0 }
end

describe command(Dynatrace::OneAgent::get_monitored_process_cmd('java -version')) do
  its(:exit_status) { should eq 0 }
end

describe file(Dynatrace::OneAgent::Java::get_monitored_process_log) do
  it { should exist }
  its(:content) { should_not match /Injection of java agent failed/ }
end