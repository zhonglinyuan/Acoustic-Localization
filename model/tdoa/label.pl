#!/usr/bin/perl

use strict;
use warnings;

my @todo = `ls`;


foreach my $i (@todo)
{
    chomp $i;
    print $i,"\n";
    my $class;
    if ($i =~ /^(.*?_.*?)_/)    {
       $class = $1; 
        unless (-d $class)  {
            mkdir $class or die;
        }
        system("mv $i $class/");
    }
}
