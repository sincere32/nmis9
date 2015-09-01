#!/usr/bin/perl
# Auto configure to the <nmis-base>/lib
use FindBin;
use lib "$FindBin::Bin/../lib";

# 
use strict;
use func;
use NMIS;
use Sys;
use NMIS::Timing;
use NMIS::Connect;
use rrdfunc;
use Data::Dumper;

my %nvp = getArguements(@ARGV);
my $C = loadConfTable;

if ($nvp{dir} or $nvp{file})
{
	my $result = getFileName(dir => $nvp{dir}, 
													 file => $nvp{file}, 
													 json => getbool($nvp{json}));
	print "getfilename for dir $nvp{dir}, file $nvp{file}, json $nvp{json} => $result\n";
	exit 0;
}

print "returndate: " . returnDate(time)."\n";
print "datestamp: " . returnDateStamp(time)."\n";
print "time: " . returnTime(time)."\n";

print "secs to hours: " . convertSecsHours(3*3600 + 10*60 + 15)."\n";

my $S=Sys->new;
$S->init(name => "ASGARD", snmp => 'false');

my ($data, $names, $meta) = getRRDasHash(sys => $S, graphtype => "cpu",
																				 mode => "AVERAGE",
																				 start => time-86400,
																				 end =>  time-6000,
																				 hour_from => 19,
																				 hour_to => 4);

print Dumper($meta, $names, $data);

# and now also check getrrdstats

my $statval = getRRDStats(sys => $S, graphtype => "cpu",
													mode => "AVERAGE",
													start => time-86400,
													end =>  time-6000,
													hour_from => 19,
													hour_to => 4);
print Dumper($statval);
