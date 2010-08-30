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

for my $x(0..65535) {
	my($n, $na, $nb) = ($x << 1, ido2abi($x << 1));
	my($s, $sa, $sb) = ($x, ido2abi($x));
	printf("%d\tb%b\t%d\t%d\t%d\tb%b\t%d\t%d\n", $n, $n, $na, $nb, $s, $s, $sa, $sb);
}