#
class base::core::usersgroups::root () {
  #
  ## Make this class private
  #

  assert_private()

  #
  ## Defaults
  #

  Ssh_authorized_key {
    user => 'root',
    type => 'ecdsa-sha2-nistp521',
  }

  #
  ## Resources
  #

  ssh_authorized_key { 'bubu@machubert.olympe.lurenzu.org for root':
    type => 'ssh-rsa',
    key  => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQDo44zzxyXFZaFSeaFtdsgcFyRtYNGL5H7B/IXNBlA26xiGgwUES/8+pvhZaKNl3mtR0IkC3xlI4pXnuJC/Xwfk2oZHw2RhdFLfRiv878arB+mL5PZ8Mkxs5oXT0N4p7Db1VeGHZxtnud7XmlsSSa2d1UH6PeZI2VA9hnHbDHuGsjPcTYyZ6dA6ybuu6Vz+hn7CtXsHxdWndZxoUqKubIhuMaGn+MMDS+PlNEygCShLZs6EO5DS3UaWBszDI2ckGfJyQMnRpM8JmLadaUATHPYwyw47z7xxyUaBeLMos2frX6HhNIRFu3INVRgDS1AMDNrKSdWTd9CifXO91jDGVmxP',
  }

  ssh_authorized_key { 'bubu@macbookhubert for root (RSA)':
    type => 'ssh-rsa',
    key  => 'AAAAB3NzaC1yc2EAAAADAQABAAACAQDA1P/EBl2ulke08g1RUjkTWGxAp/bGnlX+4igay+sPFlQwh3HkUDGhiS1kQmSF9gpt/zo7Hera2hJYWdbMpxob79moeFbMzhYHVtB05ky0xQEB28MSiisZgrwnD8CbwNeGmwlEPRZjwiu1NKutUV3SArhOU9h+3mTf5AbrXq09MuBjVPu9EoIlKEzppvYs1ZcABRUYohKSDKpwm2vhHcwCHHVrQ6WXFNs2Pmt0o0PXo+6M1/NcD9QugYTAogpyvv9wws4uwARgRMGNvVGHkGZLwbRuvsGGf4Hc99kBfT9M5ciQZh8Qh7Spmt5k5Z1kHBfCArzm70eMbwxThg8E2KvIxIm7MHTQXaUyIBCL9nyqp2ZuwDxxPXL3fRqgJV3gcrwDW+OGJBSaJSxzy9IqXXfQQ1tliVHrwhCfxDzxhoJirj21z+5ryY+ITCUv4bMMYdvXNrv0pAjpbotmXaxr78tU699mOB7uQ0jqurx1WXrV9qVsV35uz5xNjP029KQLMPc7NAlXSmKg1jewtsCHrLb4Ol+rbU/i/V1cEMcMjoAr8mn/25kzdQxEOzrLGWHyiVnOM5oMvmKnM1Y7tfXwER8Zn1rcWj1uwnJD8PhRBIVcaUvrrlRtaOqcxCwiHLV0Hd/xo6dem41OKgneW0LeGSMHIdskTlcJsfss8PbMsF68cw==',
  }

  ssh_authorized_key { 'bubu@macbookhubert for root (ECDSA)':
    key  => 'AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBAGM2fBSA+rg47jGbqm0z0quaiwkT/dsNQD8wa008O9uKRKiSDaEi7o0jRGSl6MWRxdLhYc4OlevV1E1/nApQBDCuwE/5duqPf9NikNi8EbBRz2hmqOT3y3rxc1sxTBxTh7Ks787iYexSjGtsfFHSECRo++kCPoS0a3P+VH8JXw9lJOvfQ==',
  }

  ssh_authorized_key { 'Lurenzu@Termius for root (ECDSA)':
    key  => 'AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBABvTXDQvGtI3DE46wVFoJLICQVzZZ5TPBZp6LjDguKsIuL2PjCGVHQgpXrJHdH45u9jThmxKXoT3j/xke361zz7swAGEw34BLUG0p0vGC9DIhmT4xyMXO6UebOq2uDUpc7OsBdRKaoWBGhkUHxJhCiNbKpmFsO9JRblCWnc2MH5uoudnQ==',
  }

  ssh_authorized_key { 'bubu@machubert.olympe.lurenzu.org':
    type => 'ssh-rsa',
    key  => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQDo44zzxyXFZaFSeaFtdsgcFyRtYNGL5H7B/IXNBlA26xiGgwUES/8+pvhZaKNl3mtR0IkC3xlI4pXnuJC/Xwfk2oZHw2RhdFLfRiv878arB+mL5PZ8Mkxs5oXT0N4p7Db1VeGHZxtnud7XmlsSSa2d1UH6PeZI2VA9hnHbDHuGsjPcTYyZ6dA6ybuu6Vz+hn7CtXsHxdWndZxoUqKubIhuMaGn+MMDS+PlNEygCShLZs6EO5DS3UaWBszDI2ckGfJyQMnRpM8JmLadaUATHPYwyw47z7xxyUaBeLMos2frX6HhNIRFu3INVRgDS1AMDNrKSdWTd9CifXO91jDGVmxP',
  }

  ssh_authorized_key { 'vincent':
    type => 'ssh-rsa',
    key  => 'AAAAB3NzaC1yc2EAAAABJQAAAQEAiXRrzwUDIuqJoDlDJW02qYXB6VadjYaz4afxjz/r31UdDS+Z2XAJrtiAMahkc/Nx2I2VTjA/DGJF3IrHV1nqTn/ABgaT6Xo1d03gnOaRIqgSAmi93mL3PNzUtcznaJoqevdpt1KJ4d66R48UHQUNs48YB3taVr3yPsvclk76BrKWKUT5sdIGMQSYbB2p7/doOQZkMoRkG6lxBWf/ZOZgLzwZvQqQqc7uGEbCtDwejp3qefBbIuzmuTr0E5R3Z/8WOTLwyLmd9FQlTjAxTx4NYqV0sA8b7eLDkscInoE0w0PzVlrt++ohlDt6xpEucxooYLh7dixv5rUOgyPeA6CHBw==',
  }

  ssh_authorized_key { 'root@gaia.olympe.lurenzu.org':
    key  => 'AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBAAxGJomTeRsTbNuAPBq/HOKhdUoY1ieV8+ZDHl5AXZj/zosy/yqG4LuhOm4Mv/tcicdspSpPtxBRzsjkkJtvq4ocgEvtKiDL2nbNvZD171sDRA47sUmlWSxJi2M9v5L1+dUqG5BwVfpMeFRgiC0iv59WjLILg2OuEuyygdY6VE2Foh1gw==',
  }

  ssh_authorized_key { 'root@chaos.olympe.lurenzu.org':
    key  => 'AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBAGAPthAIXAm0pTa99zDd2lsjUz4DDBEve+BhrmeS2Z9+omV3WqZ9vVpOHcFytq75jekZMZ+2N7dAqQExbh8DQJxiwFmBsYwfVwa5gr66UXky8hkuLdg0GuEtBD+ogRdbZhsQ0QNUGZxEeygQ2RhR4awXqSs0lCP+iUocD2RsZ6FaAbigA==',
  }

  ssh_authorized_key { 'root@promethee.olympe.lurenzu.org':
    key  => 'AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBAFe1LRN/Cj0QUgTMep2FEDsyyER/QRldYKUMrT/PLY0ikfWQwJHTZ5cH9az7sP926Zo5Vi5wG+d+hogMZHLZFu9CwHxRfWzkgGDmsbIkE+aLyY8PItpHcSPYKCf0q7o8jagVOa7IR4prxamV4CRGN9g/CyX2QaaC9QAccjq0wGig3KuNw==',
  }

  ssh_authorized_key { 'root@ouranos.olympe.lurenzu.org':
    key  => 'AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBAAz9RPLUOPoHIhQCEnhBEo0c3Bmi17Fzbeox4oagerLjWuQ0QO7HQrcKwwKY09nUd0zco0ZMQMWtY56dsMhag9M7gGWZD4bqyWzCT7w/KmHMGg9KtKAZPJStTFtFt3V+5dOidNM6wUv53yrRj0lBtHbqxCW2ErUMG/26s/VCLcLGyoURw==',
  }

  ssh_authorized_key { 'root@nyx.olympe.lurenzu.org':
    key  => 'AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBAHsvGDh97H05dIUFFBt9lA7qCFXHEY6ROCeDT4KFmCuGyLJvo+7HCRhMVCZ5yaRtV9jJU8StK8I/JtFGAFluzXXJgBQl3nume0PE60fGr0ak/5OPkDAa3jOaPeKDyIh1fRYutf0fRJCC0j1EY9jouhtq4uy1UK32tL1f/v1WBrCbfo6Aw==',
  }
}
