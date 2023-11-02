use strict;
use warnings;
use Getopt::Long;

my $input_file;


GetOptions(
    "input=s" => \$input_file,
);

if (!$input_file) {
    die "Usage: $0 --input input.fastq \n";
}

#mkdir "FASTQINPUT4DIVPRO";

my $output_file      = "FASTQINPUT4DIVPRO/".$input_file;


my $adapter_sequence = "AGAGTTTGATCNTGGCTCAG";  ## read 1:   AGAGTTTGATCMTGGCTCAG
if($input_file=~ m/_R2.fastq$/gix){
  $adapter_sequence = "GAATTACCGCGGCGGCTG";     ## read 2:   GWATTACCGCGGCKGCTG
};
       

open my $in_fh, '<', $input_file or die "Failed to open input file: $!";
open my $out_fh, '>', $output_file or die "Failed to open output file: $!";

my $line_count = 0;
my $sequence_added = 0;

while (my $line = <$in_fh>) {
    $line_count++;
    
    if ($line_count == 2) {
        chomp($line);
        my $sequence = $line;
        my $modified_sequence = $adapter_sequence . $sequence;
        print $out_fh $modified_sequence . "\n";
        $sequence_added = length($adapter_sequence);
    } elsif ($line_count == 4) {
        chomp($line);
        my $quality = $line;
        my $adapter_quality = substr($quality, 0, $sequence_added);
        print $out_fh $adapter_quality . $quality . "\n";
        $line_count = 0;
        $sequence_added = 0;
    } else {
        print $out_fh $line;
    }
}

close $in_fh;
close $out_fh;

print "$output_file\n";

