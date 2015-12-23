require 'spec_helper'

base_directory = '/opt'
cust_base_directory = '/tmp'
hosting_user      = 'hosting'
hosting_group     = 'hosting'
host = { 'coverity::conf' => {} }
conf = {}

describe 'coverity::dependencies', :type => 'class' do

  context "Should include all dependencies based on operating system for generic avstapp app on Debian" do
    let(:facts){{
      :osfamily => 'Debian',
      :lsbdistcodename => 'precise',
      :host => host,
    }}

    it do
      should contain_oracle_java
      should contain_limits__fragment('*/soft/nofile').with(
        'value' => '1024'
      )
      should contain_limits__fragment('*/hard/nofile').with(
        'value' => '8192'
      )
      should contain_package('libaugeas-ruby').with(
        'ensure' => 'installed',
      )
    end
  end

  context "Should include all dependencies based on operating system for generic avstapp app on RedHat" do
    let(:facts){{
      :osfamily => 'RedHat',
      :operatingsystem => 'RedHat',
      :operatingsystemrelease => '6.5',
      :host => host,
    }}

    it do
      should contain_oracle_java
      should contain_limits__fragment('*/soft/nofile').with(
        'value' => '1024'
      )
      should contain_limits__fragment('*/hard/nofile').with(
        'value' => '8192'
      )
      ['apr-util', 'neon', 'augeas'].each do |pack|
        should contain_package(pack).with(
              'ensure' => 'installed',
        )
      end
    end
  end
end
