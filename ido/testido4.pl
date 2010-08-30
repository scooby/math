no integer;

use strict;

=head1 To convert a number in base x to another base, I just do this:

	result = 0
	source = asldfjskdfj
	while(source is not empty) {
		extract digit from source
		result *= base
		result += digit
	}
	
So to convert result back to source:
	
	while(result != 0) {
		(result, digit) = result / base
		print digit
	}
	
So... I'm essentially dividing result by the base.
	
	So, how do I divide a + bi by i - 1?
	
	a + bi   (a + bi) * (i + 1)   a + ai + bi - b   (a - b) + (a + b)i
	------ = ------------------ = --------------- = ------------------
	i - 1    (i - 1) * (i + 1)    -1 - 1            -2
	
	a = (a-b)/-2
	b = (a+b)/-2

Okay, to test this out, I'm going to generate convert IDO numbers to a+ bi 
and then see what successive divisions look like.

        [[ update: wow, I fucked that up, tried dividing by 1 - i instead of i - 1. ]]

=cut

sub ido2abi {
	my $ido = shift;
	my($sa, $sb) = (0, 0); # sum of a's and b's
	my($a, $b) = (1, 0);
	while($ido) {
		my $d = $ido & 1;
		$ido >>= 1;
		($sa, $sb) = ($sa+$a, $sb+$b) if $d;
		#(a + bi) * (-1 + i)
		#-a + ai - bi - b
		#(-a-b) + (a-b)i
		($a, $b) = (-$a - $b, $a - $b);
	}
	return ($sa, $sb);
}

my %h;
$h{join("\t", ido2abi($_))}=sprintf("%d\tb%b", $_, $_) for 0..65535;
use constant smalls => 7;
my(@smla, @smlb);
($smla[$_], $smlb[$_]) = ido2abi($_) for 0..smalls; # Small numbers
#print "main\t\t\t\t";
print "-$_\t\t\t\t(-$_)/2\t\t\t\t" for 0..smalls;
print "\n";
#print "a\tbi\tido\tido\t";
print "a\tbi\tido\tido\ta\tbi\tido\tido\t" for 0..smalls;
print "\n";
for my $c (0..16384) {
	my($a, $b) = ido2abi($c);
	my(@mina) = map($a - $smla[$_], 0..smalls);
	my(@minb) = map($b - $smlb[$_], 0..smalls);
	my(@minc) = map($h{$_} || "\t", map("$mina[$_]\t$minb[$_]", 0..smalls));
	my(@diva) = map($mina[$_]-$minb[$_]/-2, 0..smalls);
	my(@divb) = map($mina[$_]+$minb[$_]/-2, 0..smalls);
	my(@divc) = map($h{$_} || "\t", map("$diva[$_]\t$divb[$_]", 0..smalls));
#	printf("%.1f\t%.1f\t%d\tb%b\t", $a, $b, $c, $c);
	printf("%.1f\t%.1f\t%s\t%.1f\t%.1f\t%s\t", $mina[$_], $minb[$_], $minc[$_], $diva[$_], $divb[$_], $divc[$_]) for 0..smalls;
	print "\n";
}