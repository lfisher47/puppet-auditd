############################################################
# Class: auditd
#
# Description:
#  This will install, configure, and run the auditd service
#
# Variables:
#  None
#
# Facts:
#  architecture -> used to select the appropiate rules for the system
#
# Files:
#  audit/files/audit.rules.x64
#  audit/files/audit.rules.x86
#
# Templates:
#  None
#
# Dependencies:
#  None
############################################################
class auditd {
  package { 'audit':
    ensure => 'latest',
  }
  #RHEL-06-000145, RHEL-06-000148, RHEL-06-000154
  service { 'auditd':
    ensure    => true,
    enable    => true,
    hasstatus => true,
    require   => Package['audit'],
  }

  #RHEL-06-000383, RHEL-06-000384, RHEL-06-000522
  file { '/var/log/audit/audit.log':
    owner => 'root',
    group => 'root',
    mode  => '0600';
  }
  #RHEL-06-000385
  file { '/var/log/audit':
    owner => 'root',
    group => 'root',
    mode  => '0700';
  }

  # Values come from suggested settings in prose guide, see man auditd.conf for more options, requires simplevars.lns
  augeas { 'Configure auditd log_file File Name':
    context => '/files/etc/audit/auditd.conf',
    lens    => 'simplevars.lns',
    incl    => '/etc/audit/auditd.conf',
    changes => 'set log_file /var/log/audit/audit.log',
  }
  #RHEL-06-000159
  augeas { 'Configure auditd Number of Logs Retained':
    context => '/files/etc/audit/auditd.conf',
    lens    => 'simplevars.lns',
    incl    => '/etc/audit/auditd.conf',
    changes => 'set num_logs 5',
  }
  #RHEL-06-000160
  augeas { 'Configure auditd Max Log File Size':
    context => '/files/etc/audit/auditd.conf',
    lens    => 'simplevars.lns',
    incl    => '/etc/audit/auditd.conf',
    changes => 'set max_log_file 6',
  }
  #RHEL-06-000161
  augeas { 'Configure auditd max_log_file_action Upon Reaching Maximum Log Size':
    context => '/files/etc/audit/auditd.conf',
    lens    => 'simplevars.lns',
    incl    => '/etc/audit/auditd.conf',
    changes => 'set max_log_file_action rotate',
  }
  #RHEL-06-000005
  augeas { 'Configure auditd space_left Action on Low Disk Space':
    context => '/files/etc/audit/auditd.conf',
    lens    => 'simplevars.lns',
    incl    => '/etc/audit/auditd.conf',
    changes => 'set space_left_action email',
  }
  augeas { 'Configure auditd admin_space_left Action on Low Disk Space':
    context => '/files/etc/audit/auditd.conf',
    lens    => 'simplevars.lns',
    incl    => '/etc/audit/auditd.conf',
    changes => 'set admin_space_left_action single',
  }
  #RHEL-06-000313
  augeas { 'Configure auditd mail_acct Action on Low Disk Space':
    context => '/files/etc/audit/auditd.conf',
    lens    => 'simplevars.lns',
    incl    => '/etc/audit/auditd.conf',
    changes => 'set action_mail_acct root',
  }
  #RHEL-06-000509
  augeas { 'Configure auditd to use audispd plugin':
    context => '/files/etc/audisp/plugins.d/syslog.conf',
    lens    => 'simplevars.lns',
    incl    => '/etc/audisp/plugins.d/syslog.conf',
    changes => 'set active yes',
    notify  => Service['auditd'],
  }
  #RHEL-06-000510
  augeas {  'Configure auditd disk_full_action Action on Audit Storage Full':
    context => '/files/etc/audit/auditd.conf',
    lens    => 'simplevars.lns',
    incl    => '/etc/audit/auditd.conf',
    changes => 'set disk_full_action syslog',
  }
  #RHEL-06-000511
  augeas { 'Configure auditd disk_error_action Action on Disk Errors':
    context => '/files/etc/audit/auditd.conf',
    lens    => 'simplevars.lns',
    incl    => '/etc/audit/auditd.conf',
    changes => 'set disk_error_action syslog',
  }

  file { '/etc/audit/audit.rules':
    owner  => 'root',
    group  => 'root',
    mode   => '0640',
    notify => Service['auditd'],
    source => "puppet:///modules/auditd/audit.rules.${::architecture}",
  }
}
