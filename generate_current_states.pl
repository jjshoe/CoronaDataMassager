#!/usr/bin/perl

use strict;
use warnings;

use DateTime;
use JSON;
use WWW::Mechanize;

use Data::Dumper;

my $browser = WWW::Mechanize->new();

my $dt = DateTime->now();

my $states =
{
  'AL' => {id => '01', count => []},
  'AK' => {id => '02', count => []},
  'AZ' => {id => '04', count => []},
  'AR' => {id => '05', count => []},
  'CA' => {id => '06', count => []},
  'CO' => {id => '08', count => []},
  'CT' => {id => '09', count => []},
  'DE' => {id => '10', count => []},
  'FL' => {id => '12', count => []},
  'GA' => {id => '13', count => []},
  'HI' => {id => '15', count => []},
  'ID' => {id => '16', count => []},
  'IL' => {id => '17', count => []},
  'IN' => {id => '18', count => []},
  'IA' => {id => '19', count => []},
  'KS' => {id => '20', count => []},
  'KY' => {id => '21', count => []},
  'LA' => {id => '22', count => []},
  'ME' => {id => '23', count => []},
  'MD' => {id => '24', count => []},
  'MA' => {id => '25', count => []},
  'MI' => {id => '26', count => []},
  'MN' => {id => '27', count => []},
  'MS' => {id => '28', count => []},
  'MO' => {id => '29', count => []},
  'MT' => {id => '30', count => []},
  'NE' => {id => '31', count => []},
  'NV' => {id => '32', count => []},
  'NH' => {id => '33', count => []},
  'NJ' => {id => '34', count => []},
  'NM' => {id => '35', count => []},
  'NY' => {id => '36', count => []},
  'NC' => {id => '37', count => []},
  'ND' => {id => '38', count => []},
  'OH' => {id => '39', count => []},
  'OK' => {id => '40', count => []},
  'OR' => {id => '41', count => []},
  'PA' => {id => '42', count => []},
  'RI' => {id => '44', count => []},
  'SC' => {id => '45', count => []},
  'SD' => {id => '46', count => []},
  'TN' => {id => '47', count => []},
  'TX' => {id => '48', count => []},
  'UT' => {id => '49', count => []},
  'VT' => {id => '50', count => []},
  'VA' => {id => '51', count => []},
  'WA' => {id => '53', count => []},
  'WV' => {id => '54', count => []},
  'WI' => {id => '55', count => []},
  'WY' => {id => '56', count => []}
};

my $dates = [];

for (my $x = 20200304; $x <= $dt->ymd(''); $x++)
{
  my $formatted_date = $x;
  $formatted_date =~ s/^(\d{4,4})(\d{2,2})(\d{2,2})$/$1\-$2\-$3/;
  push(@{$dates}, $formatted_date);

  print "Pulling data for $formatted_date\n";
  $browser->get("https://covidtracking.com/api/states/daily?date=$x");
  my $content = $browser->content();
  my $json = decode_json($content);

  for my $key (keys(%{$states}))
  {
    my $found = 0;

    if (ref($json) eq 'ARRAY')
    {
      for my $state (@{$json})
      {
  
        if ($key eq $state->{'state'})
        {
          $found++;
  
          my $death = $state->{'death'} || 0;
          my $count = $state->{'positive'} - $death;
  
          push(@{$states->{$key}->{'count'}}, $count);
          last;
        }
      }
  
      if ($found == 0)
      {
          push(@{$states->{$key}->{'count'}}, 0);
      }
    }
    else
    {
      # We got an error for the date, let's pop it off the dates array
      pop(@{$dates});
    }
  }

  #sleep(1); # don't hammer their api
}

# let's try now to account for average recovery time (https://wiki.sg/p/COVID-19:_Recovery_Patterns_in_Singapore_(2020)?fbclid=IwAR3rJ3E2GdQGJebR4TrxeCAUhPEeZ1qceQY8OnzikR7EsntJyM6exhC_wV4#Average_recovery_time)
for (my $i = scalar(@{$dates}); $i > -1; $i--)
{
  my $look_back = $i - 12;

  if ($look_back > -1)
  {
    for my $key (keys(%{$states}))
    {
      print "H: " . $states->{$key}->{'count'}->[$i] . "\n";
      print "B: " . $states->{$key}->{'count'}->[$look_back] . "\n";
      $states->{$key}->{'count'}->[$i] = $states->{$key}->{'count'}->[$i] - $states->{$key}->{'count'}->[$look_back];
    }
  }
}


my $output_line = "fips\tstate\t";
for (my $i = 0; $i < scalar(@{$dates}); $i++)
{
  $output_line .= $dates->[$i] . "\t";
}

$output_line =~ s/\t$/\n/;

print $output_line;

foreach my $state (keys(%{$states}))
{
  $output_line = $states->{$state}->{'id'} . "\t" . $state . "\t";

  for (my $i = 0; $i < scalar(@{$states->{$state}->{'count'}}); $i++)
  {
    $output_line .= $states->{$state}->{'count'}->[$i] . "\t";
  }

  $output_line =~ s/\t$/\n/;
  print $output_line;
}
