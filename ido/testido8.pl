use strict;

=head1 Progress at last!

I created ido1.pm with some actual working routines. Holy shit.

Now I'm going to work on the fractional math, first adding it to ido2abi.

	a + bi   (a + bi) * (1 + i)   a + ai + bi - b   (a - b) + (a + b)i
	------ = ------------------ = --------------- = -------   --------
	-1 + i   (-1 + i) * (1 + i)       -1 - 1          -2         -2


=cut

use constant epsilon => 0.0000000000001;

sub ido2abi {
	my $ido = int $_[0];
	my($sa, $sb) = (0, 0); # sum of a's and b's
	my($a, $b) = (1, 0);
	while($ido) {
		($sa, $sb) = ($sa+$a, $sb+$b) if $ido & 1;
		$ido >>= 1;
		#(a + bi) * (-1 + i)
		#-a + ai - bi - b
		#(-a-b) + (a-b)i
		($a, $b) = (-$a - $b, $a - $b);
	}
	$ido = abs($_[0]) - abs(int $_[0]);
	my $frac = 0.5;
	($a, $b) = (-0.5, -0.5);
	while($ido > epsilon) {
		#print($ido, $frac, "\n");
		if($ido >= $frac) {
			$ido -= $frac;
			($sa, $sb) = ($sa+$a, $sb+$b);
		}
		($a, $b) = (($a - $b) / -2, ($a + $b) / -2);
		$frac /= 2;
	}	
	return ($sa, $sb);
}

for(my $a = 0; $a <= 6; $a += 0.01) {
	printf("%f, %f, %f\n", $a, ido2abi($a));
}