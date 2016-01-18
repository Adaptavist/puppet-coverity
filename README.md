# Coverity Module
[![Build Status](https://travis-ci.org/Adaptavist/puppet-coverity.svg?branch=master)](https://travis-ci.org/Adaptavist/puppet-coverity)

## Overview

The **Coverity** installs and configures Jfrog Artifactory via the Adaptavists avst-app utility

Make sure you register an apt/yum repository where the [avst-app](https://github.com/Adaptavist/avst-app) packages are located, this can be done via the Adaptavist [packages_repo](https://github.com/Adaptavist/puppet-packages_repos) puppet module

## Configuration

The Coverity module is entirely configured in [Hiera](#hiera). Examples of Hiera configuration will be given in [YAML](#yaml), Hiera's primary backend.

The following section will present how to configure each of the module aspects
presented in the section above.

### Application server configuration

Here is a complete YAML snippet for configuring a Coverity:

    # Set users to be used for coverity instalation
    coverity::hosting_user: 'hosting'
    coverity::hosting_group: 'hosting'

    # coverity configuration 
    coverity::instance_name: 'coverity_test'
    coverity::conf:
        install_file_location: '/etc/puppet/files/bins/cov-platform-linux64-7.0.3.sh'
        license_file_location: '/etc/puppet/files/coverity/license.dat'
        admin_password: 'very_secure_password'
        connectors:
          - scheme:      "http"
            http_port:   '8080'
            redirectPort: '8443'
            protocol: "HTTP/1.1"
            connectionTimeout: '240'
          - scheme:      "http"
            http_port:   "'8443'
            protocol: "AJP/1.3" 
            redirectPort: '8443'
        db:
          DB_HOST:   'localhost'
          DB_PORT:   '5432'
          DB_DATABASE: 'coverity_db'
          DB_LOGIN:   "coverity_user'
          DB_PASSWORD:   'very_secure_password'
          DB_INSTANCE: '3'
        drivers:
          location_path:
            - '/etc/puppet/files/bins/postgresql-9.3-1102.jdbc4.jar'
        java_flags:
          JVM_MINIMUM_MEMORY: '1024m' 
          JVM_MAXIMUM_MEMORY: '2048m' 
          JVM_MAX_PERM_SIZE: '512m'
        custom:
            PROVIDER_FILESYSTEM_DIR: ''
            VERSION: '7.0.3'
            CONTEXT_PATH: '/'
            PRODUCT: coverity
            SHUTDOWN_PORT: '8012'
        
        