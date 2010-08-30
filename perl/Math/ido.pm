package Math::ido;
use Exporter qw/import/;
our(@EXPORT_OK) = qw/ido2abi abi2ido b_ido2abi b_abi2ido/;
our(%EXPORT_TAGS) = (all=>[@EXPORT_OK], big=>[grep(/^b_/, @EXPORT_OK)]);

use Math::BigInt lib => 'GMP';
use integer;
use strict;

=head1 NAME 

Math::ido - base (-1 + i) conversion 

=head1 DESCRIPTION

Math::ido (short for i dash one, as i-1 is the same as -1+i) is a
library to convert a pair of integers to a unique whole number using a
complex base conversion.

=head2 CONJECTURE

I propose that any value a + bi where a and b are integers can be
represented as a binary string c of n bits such that:

  a + bi = c[0]*(-1+i)^0 + c[1]*(-1+i)^1 + ... + c[n]*(-1+i)^n

It goes without saying that c itself is also an integer in base 2 form.
Further, although a and b are integers, c is always a whole number.

=head2 FUNCTIONS

=head3 (a, b) = ido2abi(c)

Given a whole integer c, return a + bi.

Operates as your standard base 2 conversion, only instead of each place
representing a power of 2 it represents a power of (-1 + i).

At the least significant bit, (-1 + i) ** 0 = (1 + 0i).

To find the next highest power of (-1 + i), the formula is a standard
complex multiplication:

  (a + bi) * (-1 + i) = -a + ai - bi - b
                      = (-a - b) + (a - b)i

=cut

sub ido2abi {
	my $ido = int $_[0];
	die "c can't be negative!" if $ido < 0;
	my($sa, $sb) = (0, 0); # sum of a's and b's
	my($a, $b) = (1, 0);
	while($ido) {
		($sa, $sb) = ($sa+$a, $sb+$b) if $ido & 1;
		$ido >>= 1;
		($a, $b) = (-$a - $b, $a - $b);
	}
	return ($sa, $sb);
}

=head3 (a, b) = b_ido2abi(c)

The same, only using Math::BigInt.

=cut

sub b_ido2abi {
	my $ido = new Math::BigInt($_[0]);
	die "c can't be negative!" if $ido->is_neg();
	my($sa, $sb) = (Math::BigInt->bzero(), Math::BigInt->bzero()); # sum of a's and b's
	my($a, $b) = (Math::BigInt->bone(), Math::BigInt->bzero());
	while(!$ido->is_zero()) {
		if($ido->is_odd()) {
			$sa->badd($a);
			$sb->badd($b);
		}
		$ido->brsft(1);
		my $q = $a->copy();
		$a->bneg();
		$a->bsub($b);
		$q->bsub($b);
		$b = $q;
	}
	return ($sa, $sb);
}

=head2 (c) = abi2ido(a, b)

Given the integers a and b, returns a unique integer c.

This algorithm works by repeatedly dividing a + bi by (-1 + i).

Within the loop, we check to see if the number is odd. If a + b is odd,
we know the least significant bit is 1. And we can always subtract by
one by subtracting one from a.

That guarantees us that the value is divisible by (-1 + i). Division is
by multiplication by (i + 1) / (i + 1):

	a + bi   (a + bi) * (1 + i)   a + ai + bi - b   (a - b) + (a + b)i
	------ = ------------------ = --------------- = -------   --------
	-1 + i   (-1 + i) * (1 + i)       -1 - 1          -2         -2

=cut

sub abi2ido {
	my($a, $b) = map(int, @_[0,1]);
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

=head2 (c) = b_abi2ido(a, b)

The same using Math::BigInt.

=cut

sub b_abi2ido {
	my($a, $b) = map(Math::BigInt->new($_), @_[0,1]);
	my $x = Math::BigInt->bone();
	my $ido = Math::BigInt->bzero();
	for(;;) {
		if($a->is_odd() xor $b->is_odd()) {
			$ido->badd($x);
			$a->bdec();
		}
		last if $a->is_zero() && $b->is_zero();
		my $q = $b->copy();
		$b->badd($a);
		$b->bneg();
		$b->brsft(1);
		$a->bsub($q);
		$a->bneg();
		$a->brsft(1);
		$x->blsft(1);
	}
	return $ido;
}

=head1 USES

As you can encode an binary tree, one theoretical use would be analogous
to Gödel numbers.

Say we have a typical LISP s-expression and we want to encode numbers, symbols, and CONSs.

=over 1

=item *

A null is (0, 0).

=item *

A number is encoded as (1, (a, b)).

=item *

A symbol is (2, s).

=item *

A CONS is (3, (CAR, CDR)).

=back

=head1 BUGS / CAVEATS

I honestly haven't the foggiest as to how to prove it, and I wouldn't be
surprised if it either breaks for really big numbers or is some exercise
for first year math majors.

It's not optimized at all.

It's hardly even tested.

It will happily overflow scalars.

=head1 TODO

I'm working on the math to handle rational values for a and b.

Optimizing

It may be possible to do loop unrolling for ido2abi. The powers of 
(-1 + i) have a cycle of 8, so:

	a   b	p
	1	0	0
	-1	1	1
	0	-2	2
	2	2	3
	-4	0	4
	4	-4	5
	0	8	6
	-8	-8	7
	
For the next 8 powers, multiply everything by 16.

=head1 AUTHOR

Please send bug reports / suggestions / patches to ben.samuel@gmail.com.

=cut

1;