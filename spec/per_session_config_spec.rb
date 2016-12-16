# frozen_string_literal: true
require 'spec_helper'
require 'capybara/dsl'

RSpec.describe Capybara::SessionConfig do
  describe "per session config", twtw: true do
    it "defaults to global session options" do
      Capybara.per_session_configuration = true
      session = Capybara::Session.new(:rack_test, TestApp)
      [:default_host, :app_host, :save_and_open_page_path,
       :always_include_port, :run_server, :default_selector, :default_max_wait_time, :ignore_hidden_elements,
       :automatic_reload, :match, :exact, :raise_server_errors, :visible_text_only, :wait_on_first_by_default,
       :automatic_label_click, :enable_aria_label,
       :save_path, :exact_options, :asset_host].each do |m|
         expect(session.config.public_send(m)).to eq Capybara.public_send(m)
       end
    end

    it "doesn't change global session when changed" do
      Capybara.per_session_configuration = true
      host = "http://my.example.com"
      session = Capybara::Session.new(:rack_test, TestApp) do |config|
        config.default_host = host
        config.automatic_label_click = !config.automatic_label_click
      end
      expect(Capybara.default_host).not_to eq host
      expect(session.config.default_host).to eq host
      expect(Capybara.automatic_label_click).not_to eq session.config.automatic_label_click
    end

    it "doesn't allow session configuration block when false" do
      Capybara.per_session_configuration = false
      expect do
        Capybara::Session.new(:rack_test, TestApp) { |config| }
      end.to raise_error "A configuration block is only accepted when Capybara.per_session_configuration == true"
    end

    it "doesn't allow session config when false" do
      Capybara.per_session_configuration = false
      session = Capybara::Session.new(:rack_test, TestApp)
      expect { session.config.default_selector = :title }.to raise_error /can't modify frozen/
      expect do
        session.configure do |config|
          config.exact = true
        end
      end.to raise_error /Session configuration is only supported when Capybara.per_session_configuration == true/
    end

    it "uses the config from the session" do
      Capybara.per_session_configuration = true
      session = Capybara::Session.new(:rack_test, TestApp) do |config|
        config.default_selector = :link
      end
      session.visit('/with_html')
      expect(session.find('foo').tag_name).to eq 'a'
    end
  end
end