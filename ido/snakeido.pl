use Math::ido qw/ido2abi abi2ido/;
use GD;
use integer;
use strict;

my($w, $h) = map(int, @ARGV[0, 1]);
die "Need to specify image height and width" if @ARGV < 2;
die "Height and width can't be zero or non-integers" if grep(!$_, $h, $w);

my(@frm, @ct);
{
	my $i = GD::Image->newPalette($w, $h);
	@ct = map($i->colorAllocate($_, $_, $_), 0..255);
	(@frm) = ($i);
}
open my $outf, ">", "snake.gif";
binmode $outf;
print $outf $frm[0]->gifanimbegin(1);

my($cx, $cy) = (int($w/2), int($h / 2));

my $sn = abi2ido($cx, $cy);
$sn = 5000 if $sn > 5000; # Limit to 5000 frames...

my(@tailx, @taily);
for(my $s = 0; $s < $sn; $s++) {
	my($x, $y) = ido2abi($s);
	($x, $y) = ($x + $cx, $cy - $y);
	unshift(@tailx, $x); unshift(@taily, $y);
	#$frm[0]->filledRectangle(0, 0, $w-1, $h-1, $ct[0]);
	for my $c (0..$#tailx) {
		unless(0 > $tailx[$c] || $tailx[$c] > $w 
			|| 0 > $taily[$c] || $taily[$c] > $h) {
			$frm[0]->setPixel($tailx[$c], $taily[$c], $ct[255-$c]);
		}
		if($c == 255) {
		pop @tailx; pop @taily;
		}
	}
	#if(@frm > 1) {
	#	print $outf $frm[0]->gifanimadd(0, 0, 0, 1, 1, $frm[1]);
	#	(@frm[0, 1]) = (@frm[1, 0]);
	#} else {
	#	print $outf $frm[0]->gifanimadd(0, 0, 0, 1, 1);
	#	@frm[0, 1] = ($frm[0], $frm[0]->clone());
	#}
	print $outf $frm[0]->gifanimadd(0, 0, 0, 1);
}

print $outf $frm[0]->gifanimend;
close $outf;
	