require 'serverspec'

# Required by serverspec
set :backend, :exec

ENV['HOME'] = '/tmp/kitchen/data'
require ENV['HOME'] + '/test/dynatrace/defaults.rb'
require ENV['HOME'] + '/test/dynatrace/oneagent.rb'
require ENV['HOME'] + '/test/dynatrace/util.rb'

# Test installer: NGINX, 64-bit, into /tmp)
opts = {
  DT_AGENT_BASE_URL:   Dynatrace::Defaults::DT_AGENT_BASE_URL,
  DT_API_TOKEN:        Dynatrace::Defaults::DT_API_TOKEN,
  DT_AGENT_FOR:        'nginx',
  DT_AGENT_BITNESS:    '64',
  DT_AGENT_PREFIX_DIR: '/tmp'
}

describe command(Dynatrace::Util::parse_cmd('~/paas-install.sh', opts)) do
  its(:exit_status) { should eq 0 }
end

describe command(Dynatrace::OneAgent::get_monitored_process_cmd('nginx')) do
  its(:exit_status) { should eq 0 }
end

# Cannot use file() resource here, since files appear to be evaluated immediately
describe command('cat ' + Dynatrace::OneAgent::NGINX::get_monitored_process_log) do
  its(:stdout) { should match /Nginx successfully instrumented/ }
end