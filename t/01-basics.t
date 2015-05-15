#!perl

use 5.010;
use strict;
use warnings;

use Dist::Zilla::Util::ParsePrereqsFromDistIni qw(parse_prereqs_from_dist_ini);

use Test::More 0.98;

my $src = <<'_';
[Prereqs]
A=0
B=2

[Prereqs / RuntimeRecommends]
C=0
_

my $res = parse_prereqs_from_dist_ini(src => $src);

my $expected_res = {
    runtime => {
        requires => {
            A => 0,
            B => 2,
        },
        recommends => {
            C => 0,
        },
    },
};

is_deeply($res, $expected_res) or diag explain $res;

done_testing;
