#! /usr/bin/perl -w
# Extract IP and URL from files given as arguments
# Sample :
# 66.249.72.15 - - [24/Jun/2013:06:27:45 +0200] "GET /project/miss-better/ HTTP/1.1" 200 3914 "-" "Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_1 like Mac OS X; en-us) AppleWebKit/532.9 (KHTML, like Gecko) Version/4.0.5 Mobile/8B117 Safari/6531.22.7 (compatible; Googlebot-Mobile/2.1; +http://www.google.com/bot.html)"
# Decoded version :
# <IP> - - [<DATE>] "<HTTP_METHOD> <URL> <PROTOCOLE>" <HTTP_RETURN_CODE> <SIZE> "-" "<USER_AGENT>"
# Perl date format to return apache string : [%d/%b/%Y:%H:%M:%S +0200]
# Output file will be around 176 Mo for a month with an access each 5 seconds

use strict;
use File::Find;
use DateTime;

# CONFIGURATION
# Hashes to store the informations we wanna parse
# my $log_path = "/Users/jean/Documents/Projets/F6BigData/Logs F6/";
my $log_path = $ARGV[0];
my $date_format = "%d/%b/%Y:%H:%M:%S";
my $log_template = "%s - - [%s +0200] \"GET %s HTTP/1.1\" 200 4242 \"-\" \"Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_1 like Mac OS X; en-us) AppleWebKit/532.9 (KHTML, like Gecko) Version/4.0.5 Mobile/8B117 Safari/6531.22.7 (compatible; Googlebot-Mobile/2.1; +http://www.google.com/bot.html)\"\n";
my $date_from = DateTime->new(day => 1, month => $ARGV[1], year => 2013);
my $date_to = DateTime->new(day => 1, month => ($ARGV[1] + 1), year => 2013);
# END CONFIGURATION

my %seen_ip = ();
my %seen_url = ();
find(\&parse_log, $log_path);
sub parse_log
{
  if (/access_log/)
  {
    # open file
    open (my $fh, "<", $_) or die "Unable to open $_: $!";
    # read line by line
    while (my $line = <$fh>)
    {
      # remove last character '\n'
      chomp $line;
      # extract IP
      (my $ip, $line) = split (' ', $line, 2);
      # extract URL
      (my $date, my $access, $line) = split('"', $line, 3);
      (my $method, my $url, $line) = split(' ', $access, 3);
      # store them : inc seen counter on each data
      $seen_ip{$ip}++;
      $seen_url{$url}++;
    }
    # close file
    close $fh;
  }
}

# Outputs logs
my @ips = keys %seen_ip;
my @urls = keys %seen_url;
while ($date_from->add(seconds => 5) < $date_to)
{
  printf $log_template, $ips[rand @ips], $date_from->strftime($date_format), $urls[rand @urls]
}
