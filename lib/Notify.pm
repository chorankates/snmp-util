package Notify;
use strict;
use warnings;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(send_email send_sms send_xmpp);

use lib '.';
use Util qw(_print);

require WWW::SMS;


sub send_email {
	# send_email($to, $subject, $message, [\%extended_options]) - returns 0 or error message
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

	use WWW::SMS;
	my $worker;

    #$worker = WWW::SMS->new($to, $message);
	$worker = WWW::SMS->new(
		'1', 
		'415',
		'8120487',
		'sent from perl'
		);


    print "DBGZ" if 0;

	foreach my $gateway ($worker->gateways(sorted => 'reliability')) { 
		if ($worker->send($gateway)) {
			$results = 0;
			last;
		} else {
			$results = "unable to send SMS to '$to' using gateway '$gateway'";
			_print(2, $results);
		}

        # fall through
	}

	return $results;
}

sub send_xmpp {
	# send_xmpp($to, $message, [\%extended_options]) - returns 0 or error message
}


1;
