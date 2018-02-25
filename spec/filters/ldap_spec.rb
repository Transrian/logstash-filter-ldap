# encoding: utf-8

require_relative '../spec_helper'
require "logstash/filters/ldap"

describe LogStash::Filters::Ldap do

  # You need to set-up all those environement variables to
  # test this plugin using "bundle exec rspect"
  before(:each) do
    @ldap_host=ENV["ldap_host"]
    @ldap_port=ENV["ldap_port"]
    @ldap_username=ENV["ldap_username"]
    @ldap_password=ENV["ldap_password"]
    @ldap_userdn=ENV["ldap_userdn"]
  end


  describe "check simple search" do
    let(:config) do <<-CONFIG
      filter {
        ldap {
          identifier_value => "u501565"
          host => "#{@ldap_host}"
          ldap_port => "#{@ldap_port}"
          username => "#{@ldap_username}"
          password => "#{@ldap_password}"
          userdn => "#{@ldap_userdn}"
        }
      }
      CONFIG
    end

    sample("test" => "test" ) do
      expect(subject).to include('givenName')
      expect(subject).to include('sn')

      expect(subject).not_to include('err')
      expect(subject).not_to include('tags')

      expect(subject.get("givenName")).to eq("VALENTIN")
      expect(subject.get("sn")).to eq("BOURDIER")
    end

    sample("test" => "test2" ) do
      expect(subject).to include('givenName')
      expect(subject).to include('sn')

      expect(subject).not_to include('err')
      expect(subject).not_to include('tags')

      expect(subject.get("givenName")).to eq("VALENTIN")
      expect(subject.get("sn")).to eq("BOURDIER")
    end
  end


  describe "check simple search without cache" do
    let(:config) do <<-CONFIG
      filter {
        ldap {
          identifier_value => "u501565"
          host => "#{@ldap_host}"
          ldap_port => "#{@ldap_port}"
          username => "#{@ldap_username}"
          password => "#{@ldap_password}"
          userdn => "#{@ldap_userdn}"
          use_cache => "false"
        }
      }
      CONFIG
    end

    sample("test" => "test" ) do
      expect(subject).to include('givenName')
      expect(subject).to include('sn')

      expect(subject).not_to include('err')
      expect(subject).not_to include('tags')

      expect(subject.get("givenName")).to eq("VALENTIN")
      expect(subject.get("sn")).to eq("BOURDIER")
    end

    sample("test" => "test2" ) do
      expect(subject).to include('givenName')
      expect(subject).to include('sn')

      expect(subject).not_to include('err')
      expect(subject).not_to include('tags')

      expect(subject.get("givenName")).to eq("VALENTIN")
      expect(subject.get("sn")).to eq("BOURDIER")
    end
  end


  describe "check simple search with custom object type" do
    let(:config) do <<-CONFIG
      filter {
        ldap {
          identifier_value => "u501565"
          identifier_type => "person"
          host => "#{@ldap_host}"
          ldap_port => "#{@ldap_port}"
          username => "#{@ldap_username}"
          password => "#{@ldap_password}"
          userdn => "#{@ldap_userdn}"
        }
      }
      CONFIG
    end

    sample("test" => "test" ) do
      expect(subject).to include('givenName')
      expect(subject).to include('sn')

      expect(subject).not_to include('err')
      expect(subject).not_to include('tags')

      expect(subject.get("givenName")).to eq("VALENTIN")
      expect(subject.get("sn")).to eq("BOURDIER")
    end
  end

  describe "check with false ssl settings" do
    let(:config) do <<-CONFIG
      filter {
        ldap {
          identifier_value => "u501565"
          use_ssl => true
          host => "#{@ldap_host}"
          ldap_port => "#{@ldap_port}"
          username => "#{@ldap_username}"
          password => "#{@ldap_password}"
          userdn => "#{@ldap_userdn}"
        }
      }
      CONFIG
    end

    sample("test" => "test" ) do
      expect(subject).to include('err')
      expect(subject).to include('tags')

      expect(subject).not_to include('givenName')
      expect(subject).not_to include('sn')

      expect(subject.get("tags")).to eq(["LDAP_ERR_CONN"])
      expect(subject.get("err")).to eq("Can't contact LDAP server")
    end
  end


  describe "check simple search with custom identifier" do
    let(:config) do <<-CONFIG
      filter {
        ldap {
          identifier_key => "homeDirectory"
          identifier_value => "/users/login/u501565"
          host => "#{@ldap_host}"
          ldap_port => "#{@ldap_port}"
          username => "#{@ldap_username}"
          password => "#{@ldap_password}"
          userdn => "#{@ldap_userdn}"
        }
      }
      CONFIG
    end

    sample("test" => "test" ) do
      expect(subject).to include('givenName')
      expect(subject).to include('sn')

      expect(subject).not_to include('err')
      expect(subject).not_to include('tags')

      expect(subject.get("givenName")).to eq("VALENTIN")
      expect(subject.get("sn")).to eq("BOURDIER")
    end
  end


  describe "check simple search with customs attributs" do
    let(:config) do <<-CONFIG
      filter {
        ldap {
          identifier_value => "u501565"
          host => "#{@ldap_host}"
          ldap_port => "#{@ldap_port}"
          username => "#{@ldap_username}"
          password => "#{@ldap_password}"
          userdn => "#{@ldap_userdn}"
          attributes => ["gender", "c", "dominolanguage"]
        }
      }
      CONFIG
    end

    sample("test" => "test" ) do
      expect(subject).to include('gender')
      expect(subject).to include('c')
      expect(subject).to include('dominolanguage')

      expect(subject).not_to include('givenName')
      expect(subject).not_to include('sn')
      expect(subject).not_to include('err')
      expect(subject).not_to include('tags')

      expect(subject.get("gender")).to eq("M")
      expect(subject.get("c")).to eq("FR")
      expect(subject.get("dominolanguage")).to eq("FR")
    end
  end


  describe "check bad ldap host" do
    let(:config) do <<-CONFIG
      filter {
        ldap {
          identifier_value => "u501565"
          host => "example.org"
          ldap_port => "#{@ldap_port}"
          username => "test"
          password => "test"
          userdn => "#{@ldap_userdn}"
        }
      }
      CONFIG
    end

    sample("test" => "test" ) do
      expect(subject).to include('err')
      expect(subject).to include('tags')

      expect(subject).not_to include('givenName')
      expect(subject).not_to include('sn')

      expect(subject.get("tags")).to eq(["LDAP_ERR_CONN"])
      expect(subject.get("err")).to eq("Can't contact LDAP server")
    end
  end


  describe "test bad userdn" do
    let(:config) do <<-CONFIG
      filter {
        ldap {
          identifier_value => "u501565"
          host => "#{@ldap_host}"
          ldap_port => "#{@ldap_port}"
          username => "#{@ldap_username}"
          password => "#{@ldap_password}"
          userdn => "test"
        }
      }
      CONFIG
    end

    sample("test" => "test" ) do
      expect(subject).to include('err')
      expect(subject).to include('tags')

      expect(subject).not_to include('givenName')
      expect(subject).not_to include('sn')

      expect(subject.get("tags")).to eq(["LDAP_ERR_FETCH"])
      expect(subject.get("err")).to eq("Invalid DN syntax")
    end
  end


  describe "test bad user/password couple" do
    let(:config) do <<-CONFIG
      filter {
        ldap {
          identifier_value => "u501565"
          host => "#{@ldap_host}"
          ldap_port => "#{@ldap_port}"
          username => "test"
          password => "test"
          userdn => "#{@ldap_userdn}"
        }
      }
      CONFIG
    end

    sample("test" => "test" ) do
      expect(subject).to include('err')
      expect(subject).to include('tags')

      expect(subject).not_to include('givenName')
      expect(subject).not_to include('sn')

      expect(subject.get("tags")).to eq(["LDAP_ERR_CONN"])
      expect(subject.get("err")).to eq("Can't contact LDAP server")
    end
  end

end
