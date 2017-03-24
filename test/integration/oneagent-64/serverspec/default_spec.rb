require 'serverspec'

# Required by serverspec
set :backend, :exec

ENV['HOME'] = '/tmp/kitchen/data'

# Test installer with insufficient arguments
describe command('~/paas-install.sh') do
  its(:stdout) { should eq "help...\n" }
  its(:exit_status) { should eq 1 }
end

describe command('DT_TENANT= ~/paas-install.sh') do
  its(:stdout) { should eq "help...\n" }
  its(:exit_status) { should eq 1 }
end

describe command('DT_API_TOKEN= ~/paas-install.sh') do
  its(:stdout) { should eq "help...\n" }
  its(:exit_status) { should eq 1 }
end

describe command('DT_TENANT= DT_AGENT_BASE_URL= ~/paas-install.sh') do
  its(:stdout) { should eq "help...\n" }
  its(:exit_status) { should eq 1 }
end

# Test installer with valid DT_TENANT and invalid DT_API_TOKEN
describe command('DT_TENANT=12345678 DT_API_TOKEN= ~/paas-install.sh') do
  its(:stderr) { should eq "paas-install.sh: failed to validate DT_API_TOKEN: \n" }
  its(:exit_status) { should eq 1 }
end

describe command("DT_TENANT=12345678 DT_API_TOKEN='abcdefghijklmnopqrstuvwxyz$' ~/paas-install.sh") do
  its(:stderr) { should eq "paas-install.sh: failed to validate DT_API_TOKEN: abcdefghijklmnopqrstuvwxyz$\n" }
  its(:exit_status) { should eq 1 }
end

# Test installer with invalid DT_TENANT and valid DT_API_TOKEN
describe command("DT_TENANT= DT_API_TOKEN=abcdefghijklmnopqrstuvwxyz ~/paas-install.sh") do
  its(:stderr) { should eq "paas-install.sh: failed to validate DT_TENANT: \n" }
  its(:exit_status) { should eq 1 }
end

describe command("DT_TENANT='1234567$' DT_API_TOKEN=abcdefghijklmnopqrstuvwxyz ~/paas-install.sh") do
  its(:stderr) { should eq "paas-install.sh: failed to validate DT_TENANT: 1234567$\n" }
  its(:exit_status) { should eq 1 }
end

describe command('DT_TENANT=1234567 DT_API_TOKEN=abcdefghijklmnopqrstuvwxyz ~/paas-install.sh') do
  its(:stderr) { should eq "paas-install.sh: failed to validate DT_TENANT: 1234567\n" }
  its(:exit_status) { should eq 1 }
end

describe command('DT_TENANT=123456789 DT_API_TOKEN=abcdefghijklmnopqrstuvwxyz ~/paas-install.sh') do
  its(:stderr) { should eq "paas-install.sh: failed to validate DT_TENANT: 123456789\n" }
  its(:exit_status) { should eq 1 }
end

# Test installer with invalid DT_TENANT and invalid DT_API_TOKEN
describe command("DT_TENANT= DT_API_TOKEN= ~/paas-install.sh") do
  its(:stderr) { should eq "paas-install.sh: failed to validate DT_TENANT: \n" }
  its(:exit_status) { should eq 1 }
end

describe command("DT_TENANT='1234567$' DT_API_TOKEN='abcdefghijklmnopqrstuvwxy$' ~/paas-install.sh") do
  its(:stderr) { should eq "paas-install.sh: failed to validate DT_TENANT: 1234567$\n" }
  its(:exit_status) { should eq 1 }
end

# Test installer with invalid DT_AGENT_BASE_URL and valid DT_API_TOKEN
describe command("DT_AGENT_BASE_URL= DT_API_TOKEN=abcdefghijklmnopqrstuvwxyz ~/paas-install.sh") do
  its(:stderr) { should eq "paas-install.sh: failed to validate DT_AGENT_BASE_URL: \n" }
  its(:exit_status) { should eq 1 }
end

describe command('DT_AGENT_BASE_URL=123abc DT_API_TOKEN=abcdefghijklmnopqrstuvwxyz ~/paas-install.sh') do
  its(:stderr) { should eq "paas-install.sh: failed to validate DT_AGENT_BASE_URL: 123abc\n" }
  its(:exit_status) { should eq 1 }
end

describe command("DT_AGENT_BASE_URL='http://12345678.live.dynatrace.com' DT_API_TOKEN=abcdefghijklmnopqrstuvwxyz ~/paas-install.sh") do
  its(:stderr) { should eq "paas-install.sh: failed to validate DT_AGENT_BASE_URL: http://12345678.live.dynatrace.com\n" }
  its(:exit_status) { should eq 1 }
end

# Test installer with invalid DT_AGENT_BITNESS
describe command('DT_AGENT_BITNESS=128 DT_TENANT=12345678 DT_API_TOKEN=abcdefghijklmnopqrstuvwxyz ~/paas-install.sh') do
  its(:stderr) { should eq "paas-install.sh: failed to validate DT_AGENT_BITNESS: 128\n" }
  its(:exit_status) { should eq 1 }
end

describe command('DT_AGENT_BITNESS=sixty-four DT_TENANT=12345678 DT_API_TOKEN=abcdefghijklmnopqrstuvwxyz ~/paas-install.sh') do
  its(:stderr) { should eq "paas-install.sh: failed to validate DT_AGENT_BITNESS: sixty-four\n" }
  its(:exit_status) { should eq 1 }
end

# Test installer with invalid DT_AGENT_FOR
describe command('DT_AGENT_FOR=everything-under-the-sun DT_TENANT=12345678 DT_API_TOKEN=abcdefghijklmnopqrstuvwxyz ~/paas-install.sh') do
  its(:stderr) { should eq "paas-install.sh: failed to validate DT_AGENT_FOR: everything-under-the-sun\n" }
  its(:exit_status) { should eq 1 }
end

# Test installer with invalid DT_AGENT_PREFIX_DIR
describe command("DT_AGENT_PREFIX_DIR='a' DT_TENANT=12345678 DT_API_TOKEN=abcdefghijklmnopqrstuvwxyz ~/paas-install.sh") do
  its(:stderr) { should eq "paas-install.sh: failed to validate DT_AGENT_PREFIX_DIR: a\n" }
  its(:exit_status) { should eq 1 }
end

describe command("DT_AGENT_PREFIX_DIR='a/b' DT_TENANT=12345678 DT_API_TOKEN=abcdefghijklmnopqrstuvwxyz ~/paas-install.sh") do
  its(:stderr) { should eq "paas-install.sh: failed to validate DT_AGENT_PREFIX_DIR: a/b\n" }
  its(:exit_status) { should eq 1 }
end

describe command("DT_AGENT_PREFIX_DIR='a//b' DT_TENANT=12345678 DT_API_TOKEN=abcdefghijklmnopqrstuvwxyz ~/paas-install.sh") do
  its(:stderr) { should eq "paas-install.sh: failed to validate DT_AGENT_PREFIX_DIR: a//b\n" }
  its(:exit_status) { should eq 1 }
end

describe command("DT_AGENT_PREFIX_DIR='here' DT_TENANT=12345678 DT_API_TOKEN=abcdefghijklmnopqrstuvwxyz ~/paas-install.sh") do
  its(:stderr) { should eq "paas-install.sh: failed to validate DT_AGENT_PREFIX_DIR: here\n" }
  its(:exit_status) { should eq 1 }
end

# Test installer with non-existent DT_TENANT
describe command("DT_TENANT=12345678 DT_API_TOKEN=abcdefghijklmnopqrstuvwxyz ~/paas-install.sh") do
  its(:stderr) { should match /^Connecting to 12345678.live.dynatrace.com.*404 Not Found\n$/m }
  its(:exit_status) { should eq 1 }
end

# Test installer with non-existent DT_AGENT_BASE_URL
describe command("DT_AGENT_BASE_URL=https://my-tenant.my-cluster.com DT_API_TOKEN=abcdefghijklmnopqrstuvwxyz ~/paas-install.sh") do
  its(:stderr) { should match /^Connecting to my-tenant.my-cluster.com.*404 Not Found\n$/m }
  its(:exit_status) { should eq 1 }
end

# Test installer with invalid DT_API_TOKEN
describe command("DT_AGENT_BASE_URL='https://ryx70518.dev.dynatracelabs.com' DT_API_TOKEN=abcdefghijklmnopqrstuvwxyz ~/paas-install.sh") do
  its(:stderr) { should match /^Connecting to ryx70518.dev.dynatracelabs.com.*401 Unauthorized\n$/m }
  its(:exit_status) { should eq 1 }
end

# Test installer defaults: all technologies, 64-bit into /var/lib
describe command("DT_AGENT_BASE_URL='https://ryx70518.dev.dynatracelabs.com' DT_API_TOKEN=w89AycHAQByUUfu993UHG ~/paas-install.sh") do
  its(:stdout) { should match /Installing to \/var\/lib.*Unpacking complete./m }
  its(:stderr) { should match /^Connecting to ryx70518.dev.dynatracelabs.com./m }
  its(:exit_status) { should eq 0 }
end

describe file('/var/lib/dynatrace/oneagent/dynatrace-env.sh') do
  it { should be_file }
  its(:content) { should include 'export DT_TENANT=ryx70518' }
  its(:content) { should include 'export DT_TENANTTOKEN=NkM5fd7JG1Hzmmoh' }
  its(:content) { should match /export DT_CONNECTION_POINT=".+"/ }
end

describe file('/var/lib/dynatrace/oneagent/dynatrace-agent64.sh') do
  it { should be_file }
  it { should be_executable }
end

describe file('/tmp/dynatrace-oneagent.sh') do
  it { should_not exist }
end

# Test installer: all technologies, 32/64-bit into /tmp)
describe command("DT_AGENT_BASE_URL='https://ryx70518.dev.dynatracelabs.com' DT_API_TOKEN=w89AycHAQByUUfu993UHG DT_AGENT_BITNESS=all DT_AGENT_PREFIX_DIR=/tmp ~/paas-install.sh") do
  its(:stdout) { should match /Installing to \/tmp.*Unpacking complete./m }
  its(:stderr) { should match /^Connecting to ryx70518.dev.dynatracelabs.com./m }
  its(:exit_status) { should eq 0 }
end

describe file('/tmp/dynatrace/oneagent/dynatrace-env.sh') do
  it { should be_file }
  its(:content) { should include 'export DT_TENANT=ryx70518' }
  its(:content) { should include 'export DT_TENANTTOKEN=NkM5fd7JG1Hzmmoh' }
  its(:content) { should match /export DT_CONNECTION_POINT=".+"/ }
end

describe file('/tmp/dynatrace/oneagent/dynatrace-agent32.sh') do
  it { should be_file }
  it { should be_executable }
end

describe file('/tmp/dynatrace/oneagent/dynatrace-agent64.sh') do
  it { should be_file }
  it { should be_executable }
end

describe file('/tmp/dynatrace-oneagent.sh') do
  it { should_not exist }
end