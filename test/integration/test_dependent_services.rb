require "test/unit"
require_relative '../test_helper'
require "net/http"
require 'open3'


class TestDependentServices < Test::Unit::TestCase

  def setup

    case Rails.env
    when "development"
      @port = 8080
    when "test"
      assert_not_nil(ENV['SOLR_PORT'], "ENV['SOLR_PORT'] expected to be not nil!")
      @port = ENV['SOLR_PORT']
    end
  end

  def test_solr_is_running
    uri = URI.parse("http://127.0.0.1:#{@port}/solr/#/#{Rails.env}")
    res = Net::HTTP.get_response(uri)
    assert(res.is_a? Net::HTTPOK)
  end

  def apache_is_running
  	stdin, stdout, stderr = Open3.popen3('sudo service apache2 status')
  	assert(stderr.read.empty?)
  end

  def teardown
  end
end
