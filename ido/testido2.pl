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
	
	So, how do I divide a + bi by 1 - i?
	
	a + bi   (a + bi) * (1 + i)   a + ai + bi - b   (a - b) + (a + b)i
	------ = ------------------ = --------------- = ------------------
	1 - i    (1 - i) * (1 + i)    1 + i - i + 1     2
	
	a = (a-b)/2
	b = (a+b)/2

Okay, to test this out, I'm going to generate convert IDO numbers to a+ bi 
and then see what successive divisions look like.

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

for my $c (0 .. 31) {
	my($a, $b) = ido2abi($c);
	print "IDO: $c; $a + $b i";
	for my $i (0 .. 5) {
		($a, $b) = (($a - $b) / 2, ($a + $b) / 2);
		print " / $a + ${b}i";
	}
	print "\n";
}

=head1 the results:

	IDO: 0; 0 + 0 i / 0 + 0i / 0 + 0i / 0 + 0i / 0 + 0i / 0 + 0i / 0 + 0i
	IDO: 1; 1 + 0 i / 0.5 + 0.5i / 0 + 0.5i / -0.25 + 0.25i / -0.25 + 0i / -0.125 + -0.125i / 0 + -0.125i
	IDO: 2; -1 + 1 i / -1 + 0i / -0.5 + -0.5i / 0 + -0.5i / 0.25 + -0.25i / 0.25 + 0i / 0.125 + 0.125i
	IDO: 3; 0 + 1 i / -0.5 + 0.5i / -0.5 + 0i / -0.25 + -0.25i / 0 + -0.25i / 0.125 + -0.125i / 0.125 + 0i
	IDO: 4; 0 + -2 i / 1 + -1i / 1 + 0i / 0.5 + 0.5i / 0 + 0.5i / -0.25 + 0.25i / -0.25 + 0i
	IDO: 5; 1 + -2 i / 1.5 + -0.5i / 1 + 0.5i / 0.25 + 0.75i / -0.25 + 0.5i / -0.375 + 0.125i / -0.25 + -0.125i
	IDO: 6; -1 + -1 i / 0 + -1i / 0.5 + -0.5i / 0.5 + 0i / 0.25 + 0.25i / 0 + 0.25i / -0.125 + 0.125i
	IDO: 7; 0 + -1 i / 0.5 + -0.5i / 0.5 + 0i / 0.25 + 0.25i / 0 + 0.25i / -0.125 + 0.125i / -0.125 + 0i
	IDO: 8; 2 + 2 i / 0 + 2i / -1 + 1i / -1 + 0i / -0.5 + -0.5i / 0 + -0.5i / 0.25 + -0.25i
	IDO: 9; 3 + 2 i / 0.5 + 2.5i / -1 + 1.5i / -1.25 + 0.25i / -0.75 + -0.5i / -0.125 + -0.625i / 0.25 + -0.375i
	IDO: 10; 1 + 3 i / -1 + 2i / -1.5 + 0.5i / -1 + -0.5i / -0.25 + -0.75i / 0.25 + -0.5i / 0.375 + -0.125i
	IDO: 11; 2 + 3 i / -0.5 + 2.5i / -1.5 + 1i / -1.25 + -0.25i / -0.5 + -0.75i / 0.125 + -0.625i / 0.375 + -0.25i
	IDO: 12; 2 + 0 i / 1 + 1i / 0 + 1i / -0.5 + 0.5i / -0.5 + 0i / -0.25 + -0.25i / 0 + -0.25i
	IDO: 13; 3 + 0 i / 1.5 + 1.5i / 0 + 1.5i / -0.75 + 0.75i / -0.75 + 0i / -0.375 + -0.375i / 0 + -0.375i
	IDO: 14; 1 + 1 i / 0 + 1i / -0.5 + 0.5i / -0.5 + 0i / -0.25 + -0.25i / 0 + -0.25i / 0.125 + -0.125i
	IDO: 15; 2 + 1 i / 0.5 + 1.5i / -0.5 + 1i / -0.75 + 0.25i / -0.5 + -0.25i / -0.125 + -0.375i / 0.125 + -0.25i
	IDO: 16; -4 + 0 i / -2 + -2i / 0 + -2i / 1 + -1i / 1 + 0i / 0.5 + 0.5i / 0 + 0.5i
	IDO: 17; -3 + 0 i / -1.5 + -1.5i / 0 + -1.5i / 0.75 + -0.75i / 0.75 + 0i / 0.375 + 0.375i / 0 + 0.375i
	IDO: 18; -5 + 1 i / -3 + -2i / -0.5 + -2.5i / 1 + -1.5i / 1.25 + -0.25i / 0.75 + 0.5i / 0.125 + 0.625i
	IDO: 19; -4 + 1 i / -2.5 + -1.5i / -0.5 + -2i / 0.75 + -1.25i / 1 + -0.25i / 0.625 + 0.375i / 0.125 + 0.5i
	IDO: 20; -4 + -2 i / -1 + -3i / 1 + -2i / 1.5 + -0.5i / 1 + 0.5i / 0.25 + 0.75i / -0.25 + 0.5i
	IDO: 21; -3 + -2 i / -0.5 + -2.5i / 1 + -1.5i / 1.25 + -0.25i / 0.75 + 0.5i / 0.125 + 0.625i / -0.25 + 0.375i
	IDO: 22; -5 + -1 i / -2 + -3i / 0.5 + -2.5i / 1.5 + -1i / 1.25 + 0.25i / 0.5 + 0.75i / -0.125 + 0.625i
	IDO: 23; -4 + -1 i / -1.5 + -2.5i / 0.5 + -2i / 1.25 + -0.75i / 1 + 0.25i / 0.375 + 0.625i / -0.125 + 0.5i
	IDO: 24; -2 + 2 i / -2 + 0i / -1 + -1i / 0 + -1i / 0.5 + -0.5i / 0.5 + 0i / 0.25 + 0.25i
	IDO: 25; -1 + 2 i / -1.5 + 0.5i / -1 + -0.5i / -0.25 + -0.75i / 0.25 + -0.5i / 0.375 + -0.125i / 0.25 + 0.125i
	IDO: 26; -3 + 3 i / -3 + 0i / -1.5 + -1.5i / 0 + -1.5i / 0.75 + -0.75i / 0.75 + 0i / 0.375 + 0.375i
	IDO: 27; -2 + 3 i / -2.5 + 0.5i / -1.5 + -1i / -0.25 + -1.25i / 0.5 + -0.75i / 0.625 + -0.125i / 0.375 + 0.25i
	IDO: 28; -2 + 0 i / -1 + -1i / 0 + -1i / 0.5 + -0.5i / 0.5 + 0i / 0.25 + 0.25i / 0 + 0.25i
	IDO: 29; -1 + 0 i / -0.5 + -0.5i / 0 + -0.5i / 0.25 + -0.25i / 0.25 + 0i / 0.125 + 0.125i / 0 + 0.125i
	IDO: 30; -3 + 1 i / -2 + -1i / -0.5 + -1.5i / 0.5 + -1i / 0.75 + -0.25i / 0.5 + 0.25i / 0.125 + 0.375i
	IDO: 31; -2 + 1 i / -1.5 + -0.5i / -0.5 + -1i / 0.25 + -0.75i / 0.5 + -0.25i / 0.375 + 0.125i / 0.125 + 0.25i
	
You can see that when the IDO number has 0 bits at the end it divides cleanly.
So the next step is to take the formula I devised and work out how to express remainder.

Why not try a + bi - (1 - i) when (a + b) % 1?

	a = a - 1
	b = b + 1

=cut
{
	use integer;
	for my $c (0 .. 31) {
		my($a, $b) = ido2abi($c);
		print "IDO: $c; $a + $b i";
		for my $i (0 .. 7) {
			print(abs($a + $b) % 2);
			if(abs($a + $b) % 2) {
				$a -= 1;
				$b += 1;
			}
			($a, $b) = (($a - $b) / 2, ($a + $b) / 2);
			#print " / $a + ${b}i";
		}
		print "\n";
	}
}

=head1 Not quite

	I need to work through the algorithm a bit, but this is definitely progress.

    If I have a decimal number like 10 and I'm generating a binary number from it:
    
    x = 10
    y = int(x / 2)
    
    Hold on. What's integer division really mean? It means I'm throwing out the extra bits.
    
    It also means that if I multiply the answer by 2, I might not get the same result.
    
    So if:
        z = y * 2
        m = x - z
    
    Take the IDO number 5, 101 base 2.
    
    It is
=cut