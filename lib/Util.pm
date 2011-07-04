package Util;
use strict;
use warnings;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(_print);


# are we going to have data access error trying to get to $C::settings{} ? yes


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
		open (my $fh, '>>', $C::settings{log_file}) or warn "WARN:: unable to open '$C::settings{log_file}': $!";
		print $fh $_ foreach (@msg);
		close ($fh);
																			    
		# print to STDOUT
		if ($level <= $C::levels{uc($C::settings{output_level})}) {
			print $_ foreach @_;
		}
																										    
		return;
}

1;
