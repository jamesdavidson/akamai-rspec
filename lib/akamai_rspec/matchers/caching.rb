# The be_cacheable matcher looks at the x_check_cacheable header, which is an
# Akamai-specific thing, not part of the vanilla HTTP spec.

# The matchers have_no_cache_set, not_be_cached and be_tier_distributed work by
# inspecting the cache-control, x_cache and x_check_cacheable headers. So it's a
# mix of standard and custom mechanisms.

require 'rspec'
require 'securerandom'

RSpec::Matchers.define :be_cacheable do
  match do |url|
    response = RestClient::Request.responsify url
    x_check_cacheable(response, 'YES')
    response.code == 200
  end
end

module RSpec::Matchers
  alias_method :be_cachable, :be_cacheable
end

RSpec::Matchers.define :have_no_cache_set do
  match do |url|
    response = RestClient::Request.responsify url
    cache_control = response.headers[:cache_control]
    fail('Cache-Control has been set') unless cache_control == 'no-cache'
    true
  end
end

RSpec::Matchers.define :not_be_cached do
  match do |url|
    response = RestClient::Request.responsify url
    x_check_cacheable(response, 'NO')
    response = RestClient::Request.responsify response.args[:url]  # again to prevent spurious cache miss

    not_cached = response.headers[:x_cache] =~ /TCP(\w+)?_MISS/
    unless not_cached
      fail("x_cache header does not indicate an origin hit: '#{response.headers[:x_cache]}'")
    end
    response.code == 200 && not_cached
  end
end

RSpec::Matchers.define :be_tier_distributed do
  match do |url|
    response = RestClient::Request.request_cache_miss(url)
    tiered = !response.headers[:x_cache_remote].nil?
    fail('No X-Cache-Remote header in response') unless tiered
    response.code == 200 && tiered
  end
end

def x_check_cacheable(response, should_be_cacheable)
  x_check_cacheable = response.headers[:x_check_cacheable]
  fail('No X-Check-Cacheable header?') if x_check_cacheable.nil?
  unless (x_check_cacheable == should_be_cacheable)
    fail("X-Check-Cacheable header is: #{x_check_cacheable} expected #{should_be_cacheable}")
  end
end
