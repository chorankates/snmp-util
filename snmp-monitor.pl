#!/usr/bin/perl -w
# snmp-monitor.pl -- runs SNMP queries against hosts and sends alerts based on responses

use strict;
use warnings;
use 5.010;

use Net::SMTP;
use XML::Simple; # load configurations from XML

my $config_file = shift @ARGV // 'snmp-monitor_default.rules';

# initialize and validate configuration
%C::configuration = get_xml($config_file);
%C::settings = %{$C::configuration{settings}};
# need to figure out the right way to derive the rules/hosts hashes.. XML::Simple is being uncooperative

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
    my $document = $worker->XMLin($file, KeyAttr => [ 'settings', 'name']);

    return %{$document};
}
