#!/usr/bin/perl

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
  } elsif($msg =~ /Parameters:\s*(\{.*\})\b/) {
    $last_call{$thread} = "$last_call{$thread} [Parameters: $1]";
  } elsif($was_error{$thread}) {
    $errors{$last_call{$thread}}->{$msg} += 1;
  }
  $was_error{$thread} = ($msg =~ /500 Internal Server Error/);
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
    process_message($thread, $1);
    $thread_messages{$thread} = "";
  }
}
for my $endpoint (keys %errors) {
  for my $error (keys %{$errors{$endpoint}}) {
    my $count = $errors{$endpoint}->{$error};
    print "<<Error for $endpoint [$count occurrences]>>\n$error\n\n";
  }
}
