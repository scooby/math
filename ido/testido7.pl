use strict;

=head1 Progress at last!

I created ido1.pm with some actual working routines. Holy shit.

Now I'm going to work on the fractional math, first adding it to ido2abi.

=cut

sub ido2abi {
	my $ido = int $_[0];
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

sub abi2ido {
	my($a, $b) = map(int, @_[0,1]); # Don't try to handle fractions at this point
	my $x = 1;
	my $ido = 0;
	for(;;) {
		if(($a + $b) & 1) {
			$ido += $x;
			$a--;
		}
		last if $a == 0 && $b == 0;
		($a, $b) = (($a - $b) / -2, ($a + $b) / -2);
		$x <<= 1;
	}
	return $ido;
}

