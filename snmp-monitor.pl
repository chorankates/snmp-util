#!/usr/bin/perl -w
# snmp-monitor.pl -- runs SNMP queries against hosts and sends alerts based on responses

use strict;
use warnings;
use 5.010;

use Data::Dumper;
use Net::SMTP; 
use XML::Simple; # load configurations from XML

use lib './lib/';
use Notify qw(send_email send_sms send_xmpp);
use Util qw(_print); # move snmp_q() here? 

my $foo = send_sms(14158120487, 'sent from my Perl script');

my $config_file = shift @ARGV // 'snmp-monitor_default.rules.xml';

# initialize and validate configuration
%C::config   = get_xml($config_file, 'config');
%C::settings = %{$C::config{settings}};
%C::hosts    = %{$C::config{hosts}};
%C::rules    = %{$C::config{rules}};

my $map_file = $C::settings{snmp_map} // 'snmp_map.xml';
%C::snmp = get_xml($map_file, 'snmp_map');

%C::levels = (
    DEBUG   => 4,
    INFO    => 3,
    WARNING => 2,
    ERROR   => 1,
);

$C::settings{time_start} = time;
$C::settings{log_file} = "log-$C::settings{time_start}_$0-$$.log";

if ($C::settings{output_level} eq 'debug') {
    _print(0, Dumper('%C::settings', \%C::settings));
    _print(0, Dumper('%C::hosts',    \%C::hosts));
    _print(0, Dumper('%C::rules',    \%C::rules));
    _print(0, Dumper('%C::snmp',     \%C::snmp));
}

# determine and run queries
RULE:
foreach my $rule (keys %C::rules) {
   
    my %lh = %{$C::rules{$rule}};
	
	## need to have some handling here for .* host specifications
    
	unless ($lh{active} eq 'yes') { 
		_print(3, "skipping rule '$rule' (inactive)\n");
		next RULE;                                         
	} else {
		 _print(3, "executing rule '$rule':\n");
    }
	
	HOST:
	foreach my $host (@{$lh{hosts}}) {
        # do we want any host validation here? could do a gethostbyname(), but that only works for non-IP specs

		my $password = $C::hosts{$host}{auth}{ro}; # for now, we only need RO
		my $version  = '2c'; # hardcoding for now until this is added to the schema
        my %results  = snmp_q($host, $lh{oid}, $password, $version, 'SNMP::Util');

		EXPECTED:
		foreach my $expected (@{$lh{expected}}) {
			# need to come up with 'normalized' data structure before fleshing this out
		
		}


		UNEXPECTED:
		foreach my $unexpected (@{$lh{unexpected}}) { 
			# need to come up with 'normalized' data structure before fleshing this out
		}



    }
          
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
         $document = $worker->XMLin($file, KeyAttr => [ 'settings', 'name'], GroupTags => { hosts => 'host', rules => 'rule'}) if ($type eq 'config'); # probably need to add ForceArray here
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
            oids => \($oid),
            print => 'on', # maybe not..
        );
        
        print "DBGZ" if 0;
    } elsif ($type eq 'Net::SNMP') {
        my ($session, $error) = Net::SNMP->session(
            hostname => $host,
            community => $password, # need to define this dynamically 
        );
    
        my $result = $session->get_bulk_request(
            varbindlist => \($oid),
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

