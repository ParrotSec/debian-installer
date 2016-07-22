#!/usr/bin/perl
# reduces the config file given as the first parameter, to contain only
# entries for the modules listd as the rest of the parameters.
my $file = shift;
my %modules = map { s/.*\///; s/\.k?o$//; $_ => 1} @ARGV;
open (IN, $file) || die "open $file: $!";
$/="\n\n";
my %devices;
while (<IN>) {
	s/\s*#.*//g;
	if (/device\s+\"([^"]+)\"/) {
		# This assumes the device entries come first, and the card
		# entries after.
		my $device=$1;
		if (/module\s+("[^"]+"(?:,\s+"[^"]+")*)/) {
			my $modules=$1;
			$modules=~s/"//g;
			$modules=~y/ / /s;
			my @modules=split(' ', $modules);
			my $ok=0;
			foreach (@modules) {
				$ok=1 if $modules{$_};
			}
			next unless $ok;
			$devices{$device}=1;
		}
		else {
			print STDERR "warning: cannot find modules for device $device\n";
			next;
		}
	}
	elsif (/card\s+/) {
		if (/bind\s+(.*)/) {
			my $bindline=$1;
			# support multi-purpose cards
			my $used=0;
			while ($bindline=~m/\"([^"]+)\"/g) {
				$used=1 if $devices{$1};
			}
			next unless $used;
		}
		else {
			print STDERR "warning: cannot determine bind of card in $_\n";
			next;
		}
	}
	elsif (/region\s+/) {
		# memory technology drivers, always skipped for now
		next;
	}
	elsif (/^source\s+/) {
		# keep as-is
	}
	else {
		next if /^\s*$/;
		print STDERR "warning: unknown stanza: $_\n";
	}

	print $_;
}
close IN;
