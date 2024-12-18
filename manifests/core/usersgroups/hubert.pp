#
class base::core::usersgroups::hubert () {
  #
  ## Make this class private
  #

  assert_private()

  #
  ## Defaults
  #

  File {
    ensure => directory,
    owner  => 'hubert',
    group  => 'hubert',
    seluser => 'staff_u',
    selrole => 'object_r',
    mode    => '0750',
    purge   => 'false',
  }

  Ssh_authorized_key {
    user    => 'hubert',
    require => File['/home/hubert/.ssh'],
  }

  #
  ## Resources
  #

  group {'hubert':
    gid => 1001,
  }

  user { 'hubert':
    uid     => 501,
    gid     => 'hubert',
    home    => '/home/hubert',
    require =>  Group['hubert'],
  }

  file { '/home/hubert':
    seltype => 'user_home_dir_t',
    require => User['hubert'],
  }

  file { '/home/hubert/.ssh':
    seltype => 'ssh_home_t',
    require => File['/home/hubert'],
  }

  ssh_authorized_key { 'hubert:: bubu@MacBook-Pro-de-Hubert (ECDSA)':
    name => 'bubu@MacBook-Pro-de-Hubert (ECDSA)',
    type => 'ecdsa-sha2-nistp256',
    key  => 'AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBJ5UHip75zBYrEBtgu1Lb1wzLMvWV2tth9IzaAi0fvmpD/DFNZuggCDqTk6WQMDqIIcbepUBMVPEO8c4skit0EQ=',
  }

  ssh_authorized_key { 'hubert:: bubu@macbookhubert (RSA)':
    name => 'bubu@macbookhubert for hubert (RSA)',
    type => 'ssh-rsa',
    key  => 'AAAAB3NzaC1yc2EAAAADAQABAAACAQDA1P/EBl2ulke08g1RUjkTWGxAp/bGnlX+4igay+sPFlQwh3HkUDGhiS1kQmSF9gpt/zo7Hera2hJYWdbMpxob79moeFbMzhYHVtB05ky0xQEB28MSiisZgrwnD8CbwNeGmwlEPRZjwiu1NKutUV3SArhOU9h+3mTf5AbrXq09MuBjVPu9EoIlKEzppvYs1ZcABRUYohKSDKpwm2vhHcwCHHVrQ6WXFNs2Pmt0o0PXo+6M1/NcD9QugYTAogpyvv9wws4uwARgRMGNvVGHkGZLwbRuvsGGf4Hc99kBfT9M5ciQZh8Qh7Spmt5k5Z1kHBfCArzm70eMbwxThg8E2KvIxIm7MHTQXaUyIBCL9nyqp2ZuwDxxPXL3fRqgJV3gcrwDW+OGJBSaJSxzy9IqXXfQQ1tliVHrwhCfxDzxhoJirj21z+5ryY+ITCUv4bMMYdvXNrv0pAjpbotmXaxr78tU699mOB7uQ0jqurx1WXrV9qVsV35uz5xNjP029KQLMPc7NAlXSmKg1jewtsCHrLb4Ol+rbU/i/V1cEMcMjoAr8mn/25kzdQxEOzrLGWHyiVnOM5oMvmKnM1Y7tfXwER8Zn1rcWj1uwnJD8PhRBIVcaUvrrlRtaOqcxCwiHLV0Hd/xo6dem41OKgneW0LeGSMHIdskTlcJsfss8PbMsF68cw==',
  }

  ssh_authorized_key { 'hubert:: bubu@macbookhubert (ECDSA)':
    name => 'bubu@macbookhubert for hubert (ECDSA)',
    type => 'ecdsa-sha2-nistp521',
    key  => 'AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBAGM2fBSA+rg47jGbqm0z0quaiwkT/dsNQD8wa008O9uKRKiSDaEi7o0jRGSl6MWRxdLhYc4OlevV1E1/nApQBDCuwE/5duqPf9NikNi8EbBRz2hmqOT3y3rxc1sxTBxTh7Ks787iYexSjGtsfFHSECRo++kCPoS0a3P+VH8JXw9lJOvfQ==',
  }

  ssh_authorized_key { 'hubert:: Lurenzu@Termius (ECDSA)':
    name => 'Lurenzu@Termius for hubert (ECDSA)',
    type => 'ecdsa-sha2-nistp521',
    key  => 'AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBABvTXDQvGtI3DE46wVFoJLICQVzZZ5TPBZp6LjDguKsIuL2PjCGVHQgpXrJHdH45u9jThmxKXoT3j/xke361zz7swAGEw34BLUG0p0vGC9DIhmT4xyMXO6UebOq2uDUpc7OsBdRKaoWBGhkUHxJhCiNbKpmFsO9JRblCWnc2MH5uoudnQ==',
  }

  selinux_login { 'hubert':
    seluser => 'staff_u',
  }
}
