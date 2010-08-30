use strict;
use lib '.';
use Math::ido qw/:all/;

for my $c (sort(map(int(rand() * 2**30), 0..24))) {
	my($a, $b) = ido2abi($c);
	my($d) = abi2ido($a, $b);
	printf("\n    %6d : %6d + %6di : %12d\n", $c, $a, $b, $d);
	($a, $b) = b_ido2abi($c);
	($d) = b_abi2ido($a, $b)->numify();
	printf("big %6d : %6d + %6di : %12d\n", $c, $a, $b, $d);
}

test([foo=>{re=>676, im=>328}, [undef]]);
test("blah");
test({re=>-123, im=>325645});
use Data::Dumper;

sub test {
	my($s) = $_[0];
	my $n = Dumper($s);
	print "FIRST-----------\n",$n;
	my $se = encode($s);
	print "HEX-------------\n";
	print $se->as_hex();
	print "\n";
	my $sed = decode($se);
	my $m = Dumper($sed);
	if($n ne $m) {
		print "SECOND----------\n",$m;
		print "MISMATCH!!!!!!!!\n";
	}
	return;
}

use Math::BigInt;

sub encode {
	my($n) = @_;
	unless(defined $n) {
		return Math::BigInt->bzero();
	}
	if(ref $n eq "HASH") {
		return b_abi2ido(1, b_abi2ido($n->{re}, $n->{im}));
	}
	unless(ref $n) {
		my @u = unpack("C*", $n);
		return b_abi2ido(2, "0x".sprintf("%02x" x @u, @u));
	}
	if(ref $n eq "ARRAY") {
		if(@$n == 0) {
			return b_abi2ido(4, 0);
		} elsif(@$n == 1) {
			return b_abi2ido(3, b_abi2ido(encode($n->[0]), b_abi2ido(4, 0)));
		} else {
			return b_abi2ido(3, b_abi2ido(encode($n->[0]), encode([@$n[1..$#$n]])));
		}
	}
	die "Can't encode $n!";
}

sub decode {
	my($v) = @_;
	my($t, $d) = b_ido2abi($v);
	$t = $t->numify();
	return undef if $t == 0;
	if($t == 1) {
		my($r, $i) = b_ido2abi($d);
		return {re=>$r->numify(), im=>$i->numify()};
	}
	if($t == 2) {
		die "unexpected negative" if $d->is_neg();
		my $hs = $d->as_hex;
		$hs =~ s/^0x//;
		$hs = "0$hs" if length($hs) % 2;
		return pack("C*", map(hex($_), $hs =~ /../g));
	}
	if($t == 3) {
		my($car, $cdr) = b_ido2abi($d);
		return [decode($car), @{decode($cdr)}];
	}
	return [] if $t == 4;
}