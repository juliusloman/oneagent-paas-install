require 'serverspec'

# Required by serverspec
set :backend, :exec

ENV['HOME'] = '/tmp/kitchen/data'
require ENV['HOME'] + '/test/dynatrace/defaults.rb'
require ENV['HOME'] + '/test/dynatrace/oneagent.rb'
require ENV['HOME'] + '/test/dynatrace/util.rb'

# Test installer: NodeJS, 64-bit, into /tmp)
opts = {
  DT_AGENT_BASE_URL:   Dynatrace::Defaults::DT_AGENT_BASE_URL,
  DT_API_TOKEN:        Dynatrace::Defaults::DT_API_TOKEN,
  DT_AGENT_FOR:        'nodejs',
  DT_AGENT_BITNESS:    '64',
  DT_AGENT_PREFIX_DIR: '/tmp',
  DT_AGENT_APP:        '/app/index.js'
}

describe command(Dynatrace::Util::parse_cmd('~/paas-install.sh', opts)) do
  its(:exit_status) { should eq 0 }
end

describe file("/app/index.js") do
  its(:content) { should match Regexp.new(Regexp.escape("try { require('@dynatrace/oneagent') ({ server: '#{Dynatrace::Defaults::DT_AGENT_BASE_URL}', apitoken: '#{Dynatrace::Defaults::DT_API_TOKEN}' }); } catch(err) { console.log(err.toString()); }")) }
end

describe command(Dynatrace::Util::get_fg_process('node /app/index.js', 'node')) do
  its(:stderr) { should match /Agent version.*1.*/ }
  its(:stderr) { should match /Hooking to module load procedure/ }
end