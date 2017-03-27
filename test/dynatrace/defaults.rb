module Dynatrace
  class Defaults
    DT_CLUSTER = 'dev.dynatracelabs.com'
    DT_TENANT = 'ryx70518'
    DT_TENANTTOKEN = 'NkM5fd7JG1Hzmmoh'
    DT_API_TOKEN = 'w89AycHAQByUUfu993UHG'
    DT_AGENT_BASE_URL = "https://#{Dynatrace::Defaults::DT_TENANT}.#{Dynatrace::Defaults::DT_CLUSTER}"
  end
end