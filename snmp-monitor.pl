#!/usr/bin/perl -w
# snmp-monitor.pl -- runs SNMP queries against hosts and sends alerts based on responses

use strict;
use warnings;
use 5.010;

use Net::SMTP;
use XML::Simple; # load configurations from XML

my $config_file = shift @ARGV // 'snmp-monitor.default.conf';

# initialize and validate configuration
%C::settings = get_xml();

# determine and run queries

# log out query responses

# check responses against rules/expectations

# send notices (email, sms, gtalk/jabber)


exit;

sub get_xml {
    # get_xml($file_in) - returns contents of xml file as a hash or '?'
    my $file = shift;

    return '?' unless -r $file;
    
    my $worker = XML::Simple->new();
    my $document = $worker->XMLin($file);

    return %{$document};
}
