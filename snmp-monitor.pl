#!/usr/bin/perl -w
# snmp-monitor.pl -- runs SNMP queries against hosts and sends alerts based on responses

use strict;
use warnings;
use 5.010;

use Net::SMTP;
use XML::Simple; # load configurations from XML

my $config_file = shift @ARGV // 'snmp-monitor_default.rules';

# initialize and validate configuration
%C::config = get_xml($config_file);
%C::settings = %{$C::config{settings}};
%C::hosts     = %{$C::config{hosts}};
%C::rules      = %{$C::config{rules}};

print "DBGZ" if 0;

# determine and run queries
foreach my $rule (keys %C::rules) {
    print "DBGZ" if 0;
    
}

# log out query responses

# check responses against rules/expectations

# send notices (email, sms, gtalk/jabber)


exit;

sub get_xml {
    # get_xml($file_in) - returns contents of xml file as a hash or '?'
    my $file = shift;

    return '?' unless -r $file;
    
    my $worker = XML::Simple->new();
    #my $document = $worker->XMLin($file, ForceArray => 1);
    #my $document = $worker->XMLin($file, KeyAttr => [ '+settings', '+host', '+rule']);
    my $document = $worker->XMLin($file, KeyAttr => [ 'settings', 'name'], GroupTags => { hosts => 'host', rules => 'rule'});

    return %{$document};
}

sub snmp_q {
    # snmp_q($host, $snmp, $type) - given input, returns a normalized hash
    my ($host, $snmp, $password, $type) = @_;
    my %h;
    
    if ($type eq 'Net::SMTP') {
        
    } elsif ($type eq 'snmp') {
        # snmpget -c public zeus system.sysDescr.0
        # will retrieve the variable system.sysDescr.0 from the host zeus using the community string public
        
        my $cmd = "snmpget -c $password $host $snmp";
        my $results = `$cmd`;
        
        ## now need to parse this to match the Net::SMTP data structure
        warn "WARN:: null return.. need to determine data structure";
    
    } else {
        warn "WARN:: unknown 'type': $type\n";
    }
    
    return %h;
}