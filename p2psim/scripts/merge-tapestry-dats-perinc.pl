#!/usr/bin/perl -w
use strict;

# collapse each log into one data point, print to STDOUT

my $perinc_low = shift(@ARGV);
my $perinc_high = shift(@ARGV);
my @logs = @ARGV;

#my @stats = qw( ping repair );
my @stats = qw( join nodelist mc ping backpointer mcnotify nn repair lookup );

foreach my $log (@logs) {

    if( !( -f $log ) ) {
	print STDERR "$log is not a file, skipping.\n";
	next;
    }

    open( LOG, "<$log" ) or die( "Couldn't open $log" );
    print STDERR "$log\n";

    my $base = 0; 
    my $redun = 0;
    my $rln = 0;
    my $stabtimer = 0;
    if( $log =~ /-(\d+)-(\d+)-(\d+)-(\d+).dat$/ ) {
	$base = $1;
	$redun = $2;
	$rln = $3;
	$stabtimer = $4;
    }

    my $total_time = 0;
    my $total_hops = 0;
    my $num_lookups = 0;
    my $total_msgs = 0;
    my $num_incorrect = 0;
    while(<LOG>) {
	if( /(\d+) \d+ [\w\-]+ (\d) (\d) -?(\d+) (\d+) .+ .+ .+/ ) {
	    my $time = $1;
	    my $complete = $2;
	    my $correct = $3;
	    my $hops = $4;
	    my $failures = $5;

	    $total_time += $time;
	    $total_hops += $hops;
	    $num_lookups++;
	    if( !($complete eq "1" and $correct eq "1") ) {
 		$num_incorrect++;
	    }

	} elsif( /(.+) (\d+) \d+$/ ) {

	    my $stat = $1;
	    my $msgs = $2;

	    if( grep( /$stat/, @stats ) ) {
		$total_msgs += $msgs;
	    }

	} else {
#	    die( "unrecognized line: $_" );
	    next;
	}

    }

    my $av_hop = $total_hops/$num_lookups;
    my $av_time = $total_time/$num_lookups;
    # only print it if this is an acceptable incorrectness rate
    if( ($num_incorrect*100/$num_lookups) > $perinc_low and
	($num_incorrect*100/$num_lookups) <= $perinc_high ) {
	print "\# $base $redun $rln $stabtimer:\n";
	print "$total_msgs $av_time $av_hop " . 
	    (1-$num_incorrect/$num_lookups) . "\n";
    }

    close( LOG );

}

