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

=head1 the reduce algorithm

	
You can see that when the IDO number has 0 bits at the end it divides cleanly.
So the next step is to take the formula I devised and work out how to express remainder.

Why not try a + bi - 1 when the result of division won't have a fraction?

=cut

sub reduce {
        use integer;
        my($a, $b, $l, $s) = @_;
        $l += 0;
        return ($s) if !$a && !$b;
        return () unless $l;
        my(@r);
        my($c, $d) = ($a - 1, $b);
        if(abs($c - $d) % 2 == 0 && abs($c + $d) % 2 == 0) {
            push @r, reduce(($c - $d) / -2, ($c + $d) / -2, $l - 1, "1$s");
        }
        if(abs($a - $b) % 2 == 0 && abs($a + $b) % 2 == 0) {
            push @r, reduce(($a - $b) / -2, ($a + $b) / -2, $l - 1, "0$s");
        }
        return @r;
}

{
	use integer;
	for my $c (0 .. 2**30) {
		my($a, $b) = ido2abi($c);
		my $oido = sprintf("%b", $c);
		my @r = reduce($a, $b, 10, "");
		#next if @r == 1 && $r[0] eq $oido;
		printf "IDO: %32s  ABI: %8d + %8di CNT: %12d\n", $oido, $a, $b, $c;
		printf "     %32s\n", $_ for @r;
		printf "no reduce\n" if @r == 0;
	}
}

=head1 Perfect.

Obviously this algorithm is just testing every possible way to reduce.

But it only finds the correct answer!

The only thing left to do is improve the conditional.

=head2 Until it hits $c == 1024 when reduce returns nothing.