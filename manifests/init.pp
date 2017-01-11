# 
# Installs coverity based on setup provided.
# 
# params:
# conf - default configuration of instance
# base_directory - folder for coverity
# instance_name - name of folder where coverity will reside
# hosting_user - user to own and run coverity
# hosting_group - group to own and run coverity
# work_dir - folder to store temporary data to, in case drivers, coverity tarball provided as url,
#            they will be downloaded here
#  
# coverity::conf - setup in hiera specific to host
# 'hostname':
#   coverity::conf:
#     instance_name: coverity
#     install_file_location: <http>
#     license_file_location: <path>
#     admin_password: passwd
#     db:
#        DB_TYPE=mysql
#        DB_DRIVER=com.mysql.jdbc.Driver
#        DB_URL="jdbc:mysql://localhost:3306/artdb?characterEncoding=UTF-8&elideSetAutoCommits=true"
#        DB_USER=coverity
#        DB_PASS=coverity
#        PROVIDER_FILESYSTEM_DIR=/data/coverity/filestore
#      drivers:
#              location_url:
#              location_path:
#               - '/etc/puppet/mysql-connector-java-5.1.22-bin.jar'
#      java_flags:              
#              JVM_MINIMUM_MEMORY:  '512m'
#              JVM_MAXIMUM_MEMORY: '1024m'
#              JIRA_MAX_PERM_SIZE: '256m'

class coverity(
  $instance_name     = 'coverity',
  $base_directory    = '/opt',
  $share_directory   = '/usr/share/avst-app',
  $hosting_user      = 'coverity',
  $hosting_group     = 'coverity',
  $work_dir          = '/tmp',
  $conf = {},
){

  class { 'coverity::dependencies': } ->
  Class['coverity']

  # merge custom configuration with defaults
  if $::host != undef {
    $custom_conf = $host["${name}::conf"]
    $config = $custom_conf ? {
        undef => $conf,
        default => merge($conf, $custom_conf),
    }
  } else {
    $config = $conf
  }

  # make sure that basedir exists
  file { [$base_directory, $share_directory] :
          ensure => directory,
          owner  => 'root',
          group  => 'root',
          mode   => '0755',
  }

  #make sure avst-app file exists and holds basedir and baseuser 
  file { '/etc/default/avst-app' :
    ensure  => file,
    content => template("${module_name}/etc/default/avst-app.erb"),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  $instance_dir = "${base_directory}/${instance_name}"

  # Create base directory structure
  file { $instance_dir :# , "${instance_dir}/home", "${instance_dir}/install"] :
    ensure => directory,
    owner  => $hosting_user,
    group  => $hosting_group,
  }

  # TODO: validate presence and required parameters
  $install_file_location = $config['install_file_location']
  $license_file_location = $config['license_file_location']
  $db = $config['db']
  $java_flags = $config['java_flags']
  $custom = $config['custom']
  $admin_password = $config['admin_password']
  $connectors = $config['connectors']

  # Prepare config for coverity
  file { "${instance_dir}/avst-app.cfg.sh" :
    ensure  => file,
    content => template("${module_name}/avst-app.cfg.sh.erb"),
    owner   => $hosting_user,
    group   => $hosting_group,
    mode    => '0644',
    require => File[$instance_dir],
    notify  => Exec['modify_coverity_with_avstapp'],
  }

  # # get avst-app from apt repo
  package { 'avst-app-coverity' :
          ensure  => installed,
          require => File["${instance_dir}/avst-app.cfg.sh"],
  }

  # run avst-app install with tarball passed
  exec {
      'install_coverity_with_avstapp':
          command => "avst-app --debug ${instance_name} install ${install_file_location}",
          cwd     => $instance_dir,
          creates => "${instance_dir}/.state",
          timeout => 0,
          require => [File["${instance_dir}/avst-app.cfg.sh"], Class['Database'], Package['avst-app-coverity']],
  }

  # run avst-app modify
  exec {
      'modify_coverity_with_avstapp':
          command => "avst-app --debug ${instance_name} modify",
          cwd     => $instance_dir,
          unless  => '[ grep "installed" .state ]',
          require => Exec['install_coverity_with_avstapp'],
  }

  # run avst-app install-service
  exec {
      'install_service_coverity_with_avstapp':
          command => "avst-app --debug ${instance_name} install-service",
          cwd     => $instance_dir,
          unless  => '[ grep "modified" .state ]',
          require => Exec['modify_coverity_with_avstapp'],
  }
  # celebrate
  service { $instance_name :
    ensure    => running,
    enable    => true,
    subscribe => Exec['modify_coverity_with_avstapp'],
    require   => Exec['install_service_coverity_with_avstapp'],
  }
}
