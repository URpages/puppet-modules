# Purpose: deploy oracle instant client on RHEL

class oracle_instant_client {
  # Note that oracle-instantclient is a site-specifc package.
  # We built a package that requires other oracle-instantclient-* packages
  # and also provides libclntsh.so since one of the oracle rpms
  # carelessly forgets to provide that.

  # need to rebuild this package or include -odbc and -jdbc 
  package { "oracle-instantclient":
    ensure => present,
  } 

  # Create a directory to hold configuration
  file { "/etc/oracle": 
    ensure => directory,
  }

  # put the right things in ld.so.conf.d
  $cont =  $architecture ? { 
    x86_64 => "/usr/lib/oracle/11.2/client64/lib\n", 
    i386 =>  "/usr/lib/oracle/11.2/client/lib\n",
    default => undef,
  }

  exec{ "/sbin/ldconfig":
    refreshonly => true,
    subscribe => File['/etc/ld.so.conf.d/oracle-instant.conf'],
  }

  file { "/etc/ld.so.conf.d/oracle-instant.conf":
    ensure => present,
    content => $cont,
    notify => Exec['/sbin/ldconfig']
  } 

  # Export your default TNS directory 
  file { "/etc/oracle/env.sh": 
    content => "export TNS_ADMIN=/etc/oracle\n"
  } 
  
  # Create a symlink for this file in /etc/profile.d 
  file { "/etc/profile.d/oracle.sh": 
    ensure => "/etc/oracle/env.sh"
  }
}
