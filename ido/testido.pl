use integer;
# I hardcoded it anyway
#use constant IDOLENGTH => 32;
use constant AMIN => -15;
use constant AMAX => 15;
use constant BMIN => -15;
use constant BMAX => 15;
use strict;

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

my(%ah);
my $c = 0;

for my $a (AMIN..AMAX) {
	for my $b (BMIN..BMAX) {
		$ah{"$a:$b"} = undef;
		$c++;
	}
}

my $i = 0;
while($c) {
	my($a, $b) = ido2abi($i);
	my $k = "$a:$b";
	unless(exists($ah{$k})) {
		print "Found $a, ${b}i outside realm.\n";
		;
	} else {
		if(defined $ah{$k}) {
			print "Found duplicates to $a, ${b}i: $ah{$k} & $i\n";
		} else {
			$ah{$k} = $i;
			$c--;
		}
	}
	$i++;
}

for my $a (AMIN..AMAX) {
	for my $b (BMIN..BMAX) {
		print qq/$ah{"$a:$b"}\t/;
		
	}
	print "\n";
}
