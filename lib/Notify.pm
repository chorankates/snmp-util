package Notify;
use strict;
use warnings;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(send_email send_sms send_xmpp);

sub send_email {
	# send_email($to, $subject, $message, [\%extended_options]) - returns 0 or error message
}

sub send_sms {
	# send_sms($to, $message, [\%extended_options]) - returns 0 or error message
}

sub send_xmpp {
	# send_xmpp($to, $message, [\%extended_options]) - returns 0 or error message
}


1;
