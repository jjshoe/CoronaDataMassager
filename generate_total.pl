#!/usr/bin/perl

use strict;
use warnings;

use Text::CSV;
use Data::Dumper;

system('wget -q -O data.csv https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_19-covid-Confirmed.csv');

my $state_to_fips = {
  'Alabama' => '01',
  'Alaska' => '02',
  'Arizona' => '04',
  'Arkansas' => '05',
  'California' => '06',
  'Colorado' => '08',
  'Connecticut' => '09',
  'Delaware' => '10',
  'District of Columbia' => '11',
  'Florida' => '12',
  'Georgia' => '13',
  'Hawaii' => '15',
  'Idaho' => '16',
  'Illinois' => '17',
  'Indiana' => '18',
  'Iowa' => '19',
  'Kansas' => '20',
  'Kentucky' => '21',
  'Louisiana' => '22',
  'Maine' => '23',
  'Maryland' => '24',
  'Massachusetts' => '25',
  'Michigan' => '26',
  'Minnesota' => '27',
  'Mississippi' => '28',
  'Missouri' => '29',
  'Montana' => '30',
  'Nebraska' => '31',
  'Nevada' => '32',
  'New Hampshire' => '33',
  'New Jersey' => '34',
  'New Mexico' => '35',
  'New York' => '36',
  'North Carolina' => '37',
  'North Dakota' => '38',
  'Ohio' => '39',
  'Oklahoma' => '40',
  'Oregon' => '41',
  'Pennsylvania' => '42',
  'Rhode Island' => '44',
  'South Carolina' => '45',
  'South Dakota' => '46',
  'Tennessee' => '47',
  'Texas' => '48',
  'Utah' => '49',
  'Vermont' => '50',
  'Virginia' => '51',
  'Washington' => '53',
  'West Virginia' => '54',
  'Wisconsin' => '55',
  'Wyoming' => '56'
};

open(my $fh_in, '<', 'data.csv');
open(my $fh_out, '>', 'out.tsv');

my $csv = Text::CSV->new({ sep_char => ',' });

while (my $line = <$fh_in>)
{
  chomp($line);

  if ($csv->parse($line)) {
    my @fields = $csv->fields();

    my $out_line;

    if ($fields[0] eq 'Province/State')
    {
      $out_line .= "fips\tstate\t";

      for my $i (50..scalar(@fields)) {
        $out_line .= $fields[$i] . "\t";
      }

      $out_line .= "\n";
    }
    elsif ($fields[1] eq 'US' && exists($state_to_fips->{$fields[0]}))
    {
      $out_line .= $state_to_fips->{$fields[0]} . "\t" . $fields[0] . "\t"; 

      for my $i (50..scalar(@fields)) {
        $out_line .= $fields[$i] . "\t";
      }

      $out_line .= "\n";
    }

    if ($out_line)
    {
      $out_line =~ s/\t$//g;
      $out_line =~ s/\t\n$/\n/g;
      print $fh_out $out_line;
    }
  }
  else
  {
    print "Unable to process line: $line\n";
  }
}
