#
class base::spamassassin (
  Integer       $spamass_uid,
  Integer       $spamass_gid,
  Integer       $milter_uid,
  Integer       $milter_gid,
  Stdlib::Port  $milter_port,
) {

  if $::location == 'NAS Synology - Paris' {
      package { ['spamass-milter','spamassassin']:
        ensure => purged,
      }

      file { ['/var/lib/spamassassin', '/var/lib/spamass-milter', '/etc/mail/spamassassin']:
        ensure  => absent,
        recurse => true,
        force   => true,
        purge   => true,
        require => Package['spamass-milter', 'spamassassin'],
      }
  } else {
    #
    ## Defaults
    #

    Group {
      ensure => present,
    }

    User {
      ensure => present,
      shell  => '/sbin/nologin',
    }

    File {
      seluser  => 'system_u',
      selrole  => 'object_r',
      selrange => 's0',
    }

    Service {
      ensure    => running,
      enable    => true,
    }

    #
    ## Resources
    #

    if $::hostname in ['promethee','chaos'] {
      group {'spamass':
        gid => $spamass_gid,
      }

      group {'sa-milt':
        gid => $milter_gid,
      }

      user {'spamass':
        uid     => $spamass_uid,
        gid     => $spamass_gid,
        groups  => ['spamass'],
        home    => '/var/lib/spamassassin',
        comment => 'SpamAssassin',
        require => Group['spamass'],
      }

      user {'sa-milt':
        uid     => $milter_uid,
        gid     => $milter_gid,
        groups  => ['sa-milt', 'mail', 'postfix'],
        home    => '/var/lib/spamass-milter',
        comment => 'SpamAssassin Milter',
        require => Group['sa-milt'],
      }

      file { '/var/lib/spamassassin':
        ensure  => directory,
        owner    => 'spamass',
        group    => 'spamass',
        mode    => '0644',
        seltype => 'spamd_var_lib_t',
        purge   => false,
        recurse => true,
        require => User['spamass'],
      }

      file { '/var/lib/spamass-milter':
        ensure  => directory,
        owner    => 'sa-milt',
        group    => 'sa-milt',
        mode    => '0755',
        seltype => 'spamass_milter_state_t',
        purge   => true,
        recurse => true,
        require => User['sa-milt'],
      }

      file { '/var/lib/spamass-milter/.spamassassin':
        ensure  => directory,
        owner    => 'sa-milt',
        group    => 'sa-milt',
        mode    => '0640',
        seltype => 'spamass_milter_state_t',
        purge   => false,
        recurse => true,
        require => File['/var/lib/spamass-milter'],
      }

      package { 'perl-DBD-Pg':
        before => Class['spamassassin'],
      }

      package { 'spamass-milter':
        require => [ File['/var/lib/spamass-milter'], Class['spamassassin'] ],
      }

      #  file { '/etc/mail/spamassassin/local.cf':
      #    ensure  => file,
      #    owner   => 'root',
      #    group   => 'spamass',
      #    mode    => '0640',
      #    seltype => 'etc_mail_t',
      #    content => template('base/spamassassin/spamass-local_cf.erb'),
      #    require  => Package['spamassassin'],
      #    notify  => Service['spamassassin'],
      #  }

      file { ['/etc/sysconfig/spamass-milter', '/etc/sysconfig/spamass-milter-postfix']:
        ensure  => file,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        seltype => 'etc_t',
        content => template('base/spamassassin/spamass-milter-sysconfig.erb'),
        require  => Package['spamass-milter'],
        notify  => Service['spamass-milter'],
      }

      service { 'spamass-milter':
        require   => [ Package['spamass-milter'], Class['spamassassin'] ],
        subscribe => [ User['sa-milt'], File['/var/lib/spamass-milter'] ],
      }

      class {'spamassassin':
        service_enabled              => true,
        spamd_defaults               => '-c -H',
        spamd_username               => 'spamass',
        spamd_groupname              => 'spamass',
        spamd_sql_config             => true,
        spamd_nouserconfig           => true,
        spamd_max_children           => 10,
        internal_networks            => ['10.255.0.0/16', 'fec0:255::/32', 'fe80::/32', 'fd5c:b82f:2918:613d::/64'],
        bayes_enabled                => true,
        bayes_auto_learn             => true,
        bayes_auto_expire            => true,
        bayes_sql_enabled            => true,
        bayes_store_module           => 'Mail::SpamAssassin::BayesStore::PgSQL',
        bayes_sql_dsn                => 'DBI:Pg:dbname=spamassassin;host=postgres.ip6.tartar.lurenzu.org',
        bayes_sql_username           => 'spamassassin',
        bayes_sql_password           => '86fa10fa09140bc1659cfed894ff5a646f34c8f7fe1adfdd76198767ddd74218',
        #bayes_sql_override_username => 'common',
        user_scores_dsn              => 'DBI:Pg:dbname=spamassassin;host=postgres.ip6.tartar.lurenzu.org',
        user_scores_sql_username     => 'spamassassin',
        user_scores_sql_password     => '86fa10fa09140bc1659cfed894ff5a646f34c8f7fe1adfdd76198767ddd74218',
        awl_enabled                  => false,
        awl_sql_enabled              => false,
        awl_dsn                      => 'DBI:Pg:dbname=spamassassin;host=postgres.ip6.tartar.lurenzu.org',
        awl_sql_username             => 'spamassassin',
        awl_sql_password             => '86fa10fa09140bc1659cfed894ff5a646f34c8f7fe1adfdd76198767ddd74218',

        score_tests                  => {
          'SPF_FAIL'               => 4.0,
          'SPF_HELO_FAIL'          => 4.0,
          'SPF_HELO_SOFTFAIL'      => 3.0,
          'SPF_SOFTFAIL'           => 3.0,

          'URIBL_BLACK'            => '6.0 6.5 5.0 5.0',
          'URIBL_ABUSE_SURBL'      => 3.5,
          'URIBL_DBL_SPAM'         => 3.5,

          'URI_PHISH'              => 3.0,
          'URIBL_DBL_ABUSE_PHISH'  => 3.0,

          'RCVD_IN_MSPIKE_L5'      => 4.0,
          'RCVD_IN_MSPIKE_BL'      => 3.0,
          'RCVD_IN_BL_SPAMCOP_NET' => 3.0,

          'RCVD_IN_XBL'            => 2.0,

          'MIXED_ES'               => '1.7 2.0 1.7 1.7',

          'HTML_MIME_NO_HTML_TAG'  => 2.0,
          'MIME_HTML_ONLY'         => 1.4,

          'DIET_1'                 => 4.0,
          'LOTS_OF_MONEY'          => 4.0,

          'RDNS_NONE'              => '0.0 0.5 0.5 1.5',

          'BAYES_99'               => 5.0,
          'BAYES_999'              => 5.0,
        },

        subscribe                     => [ User['spamass'], File['/var/lib/spamassassin'] ],
      }
    }
  }
}
