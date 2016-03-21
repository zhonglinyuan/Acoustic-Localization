#!/bin/usr/perl

use strict;
use warnings;

use IO::Socket;

my @buf = ();
my $count = 0;

my $sock = new IO::Socket::INET (
                                 LocalPort => '9001',
                                 Proto => 'tcp',
                                 Listen => 1,
                                 Reuse => 1,
                                );
die "Could not create socket: $!\n" unless $sock;

chdir("received");
system("rm count*.txt");

my $new_sock = $sock->accept();
while(<$new_sock>) {
    my $line = $_;
    chomp $line;

    if ($line =~ /^START$/)
    {
        print "start  detected\n";
        next;
    }

    if ($line =~ /^END$/)
    {
        my $check = scalar(@buf);
        print "end detected\n";
        my $fileName = "count$count.txt";
        open FH, ">",$fileName;
        print FH @buf;
        close FH;
        $count = $count + 1;
        @buf = ();
    }
    else
    {
        push @buf,$line;
    }
}
close($sock);
