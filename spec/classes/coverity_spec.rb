require 'spec_helper'
 
base_directory = '/opt'
instance_name = 'coverity'
instance_dir = "#{base_directory}/#{instance_name}"
cust_base_directory = '/tmp'
hosting_user      = 'hosting'
hosting_group     = 'hosting'
host = { 'coverity::conf' => {} }
conf = {
  'license_file_location' => '/tmp/coverity.lic',
  'install_file_location' => '/etc/puppet/files/coverity/cov-platform-linux64-7.0.3.sh',
  'admin_password' => 'password123'
}
custom_host = { 
  'coverity::conf' => {
    'license_file_location' => '/tmp/coverity.lic',
    'install_file_location' => '/etc/puppet/files/coverity/cov-platform-linux64-7.0.3.sh',
    'admin_password' => 'password123'
  } 
}

describe 'coverity', :type => 'class' do
  
  context "Should create base dir, avst-app file and instantiate resources" do
    let(:facts){{
      :osfamily => 'Debian',
      :lsbdistid => 'Ubuntu',
      :lsbdistcodename => 'precise',
      :host => custom_host,
    }}
    it do
      should contain_class('oracle_java')
      should contain_file(base_directory).with(
          'ensure'  => 'directory',
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0755',
      )
      should contain_file('/etc/default/avst-app').with(
        'ensure'  => 'file',
        'owner'   => 'root',
        'group'   => 'root',
        'mode'    => '0644',
      ).with_content(/BASE_DIR=\/opt/)
      .with_content(/INSTANCE_USER=coverity/)
    end
  end
  context "Should create base dir, avst_app file and instantiate resources with custom params" do
    let(:params){{
      :base_directory => cust_base_directory,
      :hosting_user => hosting_user,
      :hosting_group => hosting_group,
      :conf => conf, 
    }}
    let(:facts){{
      :osfamily => 'Debian',
      :lsbdistid => 'Ubuntu',
      :lsbdistcodename => 'precise',
    }}
    it do
      should contain_class('oracle_java')
      should contain_file(cust_base_directory).with(
          'ensure'  => 'directory',
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0755',
      )
      should contain_file('/etc/default/avst-app').with(
        'ensure'  => 'file',
        'owner'   => 'root',
        'group'   => 'root',
        'mode'    => '0644',
      ).with_content(/BASE_DIR=#{cust_base_directory}/)
      .with_content(/INSTANCE_USER=#{hosting_user}/)

    end
  end
  context "Should create dirs, download tar from url, extract tar and prepare avst-app.conf.sh " do
  let(:facts){{
    :osfamily => 'Debian',
    :lsbdistcodename => 'precise',
    :lsbdistid => 'Ubuntu',
    :host => host,
  }}
  let(:params){{
    :conf => conf,
  }}

    it do
    should contain_class('coverity')
    [instance_dir].each do |file_name|
        should contain_file( file_name ).with(
          'ensure' => 'directory',
          'owner'  => 'coverity',
          'group'  => 'coverity',
      )
      end

      should contain_file("#{instance_dir}/avst-app.cfg.sh").with(
        'ensure'  => 'file',
        'owner'   => 'coverity',
        'group'   => 'coverity',
        'mode'    => '0644',
        'require' => "File[#{instance_dir}]",
    )
    end
  end

  context "Should create dirs, extract tar, prepare avst-app.conf.sh when tar_path is provided" do

  let(:facts){{
    :osfamily => 'Debian',
    :lsbdistcodename => 'precise',
    :lsbdistid => 'Ubuntu',
    :host => host,
  }}
  let(:params){{
    :conf => conf,
    :hosting_user => hosting_user,
    :hosting_group => hosting_group,
  }}

    it do
    should contain_class('coverity')
    [instance_dir].each do |file_name|
        should contain_file( file_name ).with(
          'ensure' => 'directory',
          'owner'  => hosting_user,
          'group'  => hosting_group,
      )
      end

      should contain_file("#{instance_dir}/avst-app.cfg.sh").with(
        'ensure'  => 'file',
        'owner'   => hosting_user,
        'group'   => hosting_group,
        'mode'    => '0644',
        'require' => "File[#{instance_dir}]",
    )
    end
  end

end

