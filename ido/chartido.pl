use Math::ido qw/abi2ido/;
use GD;
use integer;
use strict;

my($w, $h) = map(int, @ARGV[0, 1]);
die "Need to specify image height and width" if @ARGV < 2;
die "Height and width can't be zero or non-integers" if grep(!$_, $h, $w);

my $i = GD::Image->newTrueColor($w, $h);
my @ct;
my $hueSize = 255;
# Red       R 0 0
# Orange    R x
# Yellow    R G 0
# YG       -x G
# Green     0 G 0
# CG          G x
# Cyan      0 G B
# CB         -x B
# Blue      0 0 B
# BM        x   B
# Magenta   R 0 B
# MR        R  -x
for my $hue (0..2) {
	for my $shade (0..$hueSize) {
		my(@c) = (0, 0, 0);
		$c[$hue] = 255;
		$c[($hue + 1) % 3] = $shade * 255 / $hueSize;
		push @ct, $i->colorAllocate(@c);
	}
	for my $shade (1..$hueSize) {
		my(@c) = (0, 0, 0);
		$c[$hue] = ($hueSize - $shade) * 255 / $hueSize;
		$c[($hue + 1) % 3] = 255;
		push @ct, $i->colorAllocate(@c);
	}
}
$hueSize = scalar @ct;
my($cx, $cy) = (int($w/2), int($h / 2));
for(my $x = 0; $x < $w; $x++) {
	for(my $y = 0; $y < $h; $y++) {
		my $n = abi2ido($x - $cx, ($h - $y) - $cy) % $hueSize;
		$n += $hueSize if $n < 0;
		$i->setPixel($x, $y, $ct[$n]);
	}
}
open my $outf, ">", "output.png";
binmode $outf;
print $outf $i->png;
close $outf;
	