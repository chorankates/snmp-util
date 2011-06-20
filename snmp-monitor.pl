#!/usr/bin/perl -w
# snmp-monitor.pl -- runs SNMP queries against hosts and sends alerts based on responses

use strict;
use warnings;
use 5.010;

use Data::Dumper;
#use Net::SMTP; # not actually using this right now
use SNMP::Util; # having trouble compiling this on 10.10
use XML::Simple; # load configurations from XML

my $config_file = shift @ARGV // 'snmp-monitor_default.rules.xml';

# initialize and validate configuration
%C::config = get_xml($config_file, 'config');
%C::settings = %{$C::config{settings}};
%C::hosts     = %{$C::config{hosts}};
%C::rules      = %{$C::config{rules}};

my $map_file = $C::settings{snmp_map} // 'snmp_map.xml';
%C::snmp = get_xml($map_file, 'snmp_map');

%C::levels = (
    DEBUG     => 4,
    INFO        => 3,
    WARNING => 2,
    ERROR     => 1,
);

$C::settings{time_start} = time;
$C::settings{log_file} = "log-$0.log";

print "DBGZ" if 0;

if ($C::settings{output_level} eq 'debug') {
    _print(0, Dumper(\%C::settings));
    _print(0, Dumper(\%C::hosts));
    _print(0, Dumper(\%C::rules));
}

# determine and run queries
foreach my $rule (keys %C::rules) {
   
    my %lh = $C::rules{$rule};
    
    print "DBGZ" if 0;   

}

# log out query responses

# check responses against rules/expectations

# send notices (email, sms, gtalk/jabber)

## cleanup
$C::settings{time_finish} = time;



exit;

sub get_xml {
    # get_xml($file_in, $type) - returns contents of xml file as a hash or '?'
    my ($file, $type) = @_;

    return '?' unless -r $file;
    
    my $worker = XML::Simple->new();
    #my $document = $worker->XMLin($file, ForceArray => 1);
    #my $document = $worker->XMLin($file, KeyAttr => [ '+settings', '+host', '+rule']);
    my $document;
    eval {
         $document = $worker->XMLin($file, KeyAttr => [ 'settings', 'name'], GroupTags => { hosts => 'host', rules => 'rule'}) if ($type eq 'config');
         $document = $worker->XMLin($file) if ($type eq 'snmp_map');
    };
    
    return { } if ($@);
    
    return %{$document};
}

sub snmp_q {
    # snmp_q($host, $oid, $type) - given input, returns a normalized hash
    my ($host, $oid, $password, $type) = @_;
    my %h;
    
    if ($type eq 'SNMP::Util') {
        my $worker = new SNMP::Util(
            -device => $host,
            -community => $password,
        );
        
        %h = $worker->walk(
            -oids => \@oid,
            -print => on, # maybe not..
        );
        
        print "DBGZ" if 0;
        
    } elsif ($type eq 'snmp') {
        # snmpget -c public zeus system.sysDescr.0
        # will retrieve the variable system.sysDescr.0 from the host zeus using the community string public
        
        my $cmd = "snmpget -c $password $host $oid";
        my $results = `$cmd`;
        
        ## now need to parse this to match the Net::SMTP data structure
        warn "WARN:: null return.. need to determine data structure";
        
        # system.sysDescr.0 = "SunOS zeus.net.cmu.edu 4.1.3_U1 1 sun4m"
    
    } else {
        warn "WARN:: unknown 'type': $type\n";
    }
    
    return %h;
}

sub _print {
    # _print($level, $message) - if $level >= $C::settings{output_level}, print to STDOUT, always log
    my $level = shift;
    my @msg = @_;
    
    if ($level !~ /\d/) {
        # allow calls without levels, force print it
        $msg[0] = $level;
        $level = 0;
    }
    
    # print to the log file
    open (my $fh, '<', $C::settings{log_file}) or warn "WARN:: unable to open '$C::settings{log_file}'";
    print $fh $_ foreach (@msg);
    close ($fh);
    
    # print to STDOUT
    if ($level <= $C::levels{uc($C::settings{output_level})}) {
        print $_ foreach @_;
    }
    
    return;
}