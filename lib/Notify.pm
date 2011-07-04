package Notify;
use strict;
use warnings;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(send_email send_sms send_xmpp);

use lib '.';
use Util qw(_print);

use Net::SMTP;   # few dependencies, ugly interface and plain text
#use MIME::Lite; # more dependencies, heavier, HTML/attachments allowed
require WWW::SMS;


sub send_email {
	# send_email($to, $subject, $message, [\%extended_options]) - returns 0 or error message
    my ($to, $subject, $message, $href) = @_;
	my ($from, $server_host, $server_port, $server_username, $server_password); # supported keys in %extended_options
	my $method = 'Net::SMTP'; # do not support MIME::Lite yet
	my $results = 1;

	chomp(my $hostname = `hostname`);
	# come up with a better/shorter way to guarantee expected outcome here
	$from = (defined $href and ref $href eq 'HASH' and $href->{from}) ? $href->{from} : 'notify@' . $hostname;
	$server_host = (defined $href and ref $href eq 'HASH' and $href->{server_host}) ? $href->{server_host} : 'localhost';
	$server_port = (defined $href and ref $href eq 'HASH' and $href->{server_port}) ? $href->{server_port} : 25;

	# authentication not supported yet
	$server_username = (defined $href and ref $href eq 'HASH' and $href->{server_username}) ? $href->{server_username} : undef;
	$server_password = (defined $href and ref $href eq 'HASH' and $href->{server_password}) ? $href->{server_password} : undef;

	if ($method eq 'Net::SMTP') {
		# need to introduce some error checking below
        my $worker = Net::SMTP->new($server_host . ':' . $server_port);
		   $worker->mail($from);
		   $worker->to($to);

		   $worker->datasend("To: $to\n");
		   $worker->datasend("Subject: $subject\n");
		   $worker->datasend($message);
		   $worker->dataend();

		   $worker->quit;		                      

		# for now, if we make it this far, assume success
		$results = 0;
	
	} elsif ($method eq 'MIME::Lite') { 
		$results = "MIME::Lite support incomplete, use Net::SMTP";
	} else {
		$results = "unknown method/module '$method'";
		# fall through works for now..
	}

    return $results;
}

sub send_sms {
	# send_sms($to, $message, [\%extended_options]) - returns 0 or error message
	my ($to, $message, $href) = @_;
	my $results = 1;

	# the gateway provided with WWW::SMS (GoldenTelecom) is dead
	# https://www.zeepmobile.com/ seems like a good idea, but seems more PHP/webish.. 
	# couple other ideas: http://justtechnika.com/articles/free-sms-gateway-api/

	if (defined $href and ref $href eq 'HASH') { 
		# overload internal variables with user supplied ones
	}


	return $results;
}

sub send_xmpp {
	# send_xmpp($to, $message, [\%extended_options]) - returns 0 or error message
}


1;
