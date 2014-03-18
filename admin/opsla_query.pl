#!/usr/bin/perl
#
## $Id: opsla_delete_probes.pl,v 1.2 2012/05/16 05:23:45 keiths Exp $
#
#  Copyright (C) Opmantek Limited (www.opmantek.com)
#
#  ALL CODE MODIFICATIONS MUST BE SENT TO CODE@OPMANTEK.COM
#
#  This file is part of Network Management Information System ("NMIS").
#
#  NMIS is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  NMIS is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with NMIS (most likely in a file named LICENSE).
#  If not, see <http://www.gnu.org/licenses/>
#
#  For further information on NMIS or for a license other than GPL please see
#  www.opmantek.com or email contact@opmantek.com
#
#  User group details:
#  http://support.opmantek.com/users/
#
# *****************************************************************************

use FindBin;
use lib "$FindBin::Bin/../lib";

# Include for reference
#use lib "/usr/local/nmis8/lib";

# 
use strict;
use Fcntl qw(:DEFAULT :flock);
use func;
use NMIS;
use NMIS::IPSLA;
use NMIS::Timing;
use Data::Dumper;
use Net::hostent;
use Socket;

my $t = NMIS::Timing->new();

print $t->elapTime(). " Begin\n";

# Variables for command line munging
my %arg = getArguements(@ARGV);

# Set debugging level.
my $debug = setDebug($arg{debug});
#$debug = $debug;

# load configuration table
my $C = loadConfTable(conf=>$arg{conf},debug=>$arg{debug});

my $log = "$C->{'<nmis_base>'}/admin/ipsla+_fix_error_probes.log";

if ( $ARGV[0] eq "" ) {
	print <<EO_TEXT;
ERROR: $0 will view probes.
usage: $0 probe=(probe id)
eg: $0 probe=wanedge1_branch1_jitter_96

EO_TEXT
	exit 1;
}

print $t->markTime(). " Creating IPSLA Object\n";
my $IPSLA = NMIS::IPSLA->new(C => $C);
print "  done in ".$t->deltaTime() ."\n";

if ( defined $arg{probe} and $IPSLA->existProbe(probe => $arg{probe}) ) {
	print $t->elapTime(). " PROBE FOUND, Viewing $arg{probe}\n";
	my $probe = $IPSLA->getProbe(probe => $arg{probe});
	print Dumper $probe;
}
elsif ( $arg{dns} ) {
	print $t->elapTime(). " Looking up DNS $arg{dns}\n";
	my $dns = $IPSLA->getDns(lookup => $arg{dns});
	print Dumper $dns;

	my $oct = resolveDNS($arg{dns})
	print 
}
else {
	print $t->elapTime(). " ERROR NO PROBE FOUND, $arg{probe}\n";

}

# message with (class::)method names and line number
sub logit {
	my $msg = shift;
	my $handle;
	open($handle,">>$log") or warn returnTime." log, Couldn't open log file $log. $!\n";
	flock($handle, LOCK_EX)  or warn "log, can't lock filename: $!";
	print $handle returnDateStamp().",$msg\n" or warn returnTime." log, can't write file $log. $!\n";
	close $handle or warn "log, can't close filename: $!";
}

sub resolveDNS {
	my $dns = shift;
	my $addr;
	my $oct;
	my $h;
	
	# convert node name to oct ip address
	if ($dns ne "") {
		if ($dns !~ /^([0-9]|\.)+/) {
			if ($h = gethostbyname($dns)) {
				$addr = inet_ntoa($h->addr);
			}
			else {
				return undef;
			}
		} 
		else { 
			$addr = $dns; 
		}
		my @octets=split(/\./,$addr);
		$IPSLA->updateDnsCache(lookup => $dns, result => $addr);
		$RTTcache{dns}{$dns} = $addr;
		$oct= pack ("CCCC", @octets);
		return $oct;
	} 
	else {
		return undef;
	}
}