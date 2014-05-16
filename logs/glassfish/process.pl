#!/usr/bin/perl

# Script for processing the logs coming out of DRF's glassfish server, an example of which is example.log.

use warnings;
use strict;

my %errors = ();
my %last_call = ();
my %was_error = ();
sub process_message($$) {
  my $thread = shift;
  my $msg = shift;
  if($msg =~ /Started ([A-Z]{3,4} ".*?")/) {
    $last_call{$thread} = $1;
  } elsif($was_error{$thread}) {
    $errors{$msg}->{$last_call{$thread}} += 1;
  }
  $was_error{$thread} = ($msg =~ /Completed 5\d\d .* in \d+ms/);
}

my $thread = "";
my %thread_messages = ();
while(<>) {
  chomp;
  next if /^\s*$/;
  if(/\|_ThreadID=(\d+);_ThreadName=/) {
    $thread = $1;
  }
  my $current_message = $thread_messages{$thread};
  $current_message = "" unless $current_message;
  if(/^\[#\|.*?ServletContext.log\(\):\s*(.*?)\s*$/s) {
    $current_message = $1;
  } else {
    $current_message = "$current_message\n$_";
  }
  $thread_messages{$thread} = $current_message;
  if($current_message =~ /^\s*(.+?)\s*\|#\]\s*$/s) {
    $current_message = $1;
    $current_message =~ s/#<\w+:0x\w+>/#<Class:0x...>/;
    process_message($thread, $current_message);
    $thread_messages{$thread} = "";
  }
}

my %error_count = ();
for my $error (keys %errors) {
  my %error_endpoints = %{$errors{$error}};
  for my $endpoint (keys %{$errors{$error}}) {
    $error_count{$error} += $errors{$error}->{$endpoint};
  }
}

for my $error (keys %errors) {
  print "<<Error [$error_count{$error} total occurrences]>>\n$error\n<<Endpoints>>\n";
  for my $endpoint (keys %{$errors{$error}}) {
    my $count = $errors{$error}->{$endpoint};
    print "\t$endpoint [$count occurrences]\n";
  }
  print "\n";
}
