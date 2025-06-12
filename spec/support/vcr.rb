require 'vcr'

VCR.configure do |config|
  config.allow_http_connections_when_no_cassette = true
  config.cassette_library_dir = Rails.root.join('spec/fixtures/vcr_cassettes')
  config.configure_rspec_metadata!
  config.hook_into :faraday
end
