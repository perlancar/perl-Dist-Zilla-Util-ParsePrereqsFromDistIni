package Dist::Zilla::Util::ParsePrereqsFromDistIni;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;

require Exporter;
our @ISA = qw(Exporter);
our @ISA = qw(parse_prereqs_from_dist_ini);

our %SPEC;

$SPEC{parse_prereqs_from_dist_ini} = {
    v => 1.1,
    summary => "Parse prereqs from dzil's dist.ini",
    description => <<'_',

This routine tries to get prereqs solely from reading Dist::Zilla's `dist.ini`
(from Prereqs and Prereqs/* sections, as well as from OsPrereqs, see
`lint-prereqs` utility).

The downside is that the routine can't detect prereqs that are added dynamically
during dist building process, e.g. from AutoPrereqs plugin and so on. But the
upside is that this routine can be used outside dzil and/or for `dist.ini` of
other dists (not the current dist during dzil build process).

See also: `lint-prereqs`, `Dist::Zilla::Util::CombinePrereqsFromDistInis`.

_
    args_rels => {
        req_one => [qw/path src/],
    },
    args => {
        path => {
            summary => 'Path to dist.ini',
            schema => 'str*',
            'x.schema.entity' => 'filename',
        },
        src => {
            summary => 'Content of dist.ini',
            schema => 'str*',
        },
    },
    naked_result => 1,
};
sub parse_prereqs_from_dist_ini {
    require Config::IOD::Reader;

    my %args = @_;

    my $reader = Config::IOD::Reader->new(
        ignore_unknown_directive => 1,
    );

    my $confhash;
    if ($args{path}) {
        $confhash = $reader->read_file($args{path});
    } else {
        $confhash = $reader->read_string($args{src});
    }

    my $res;
    for my $section (sort keys %$confhash) {
        my ($phase, $rel);
        if ($section =~ m!\A(os)?prereqs\z!i) {
            $phase = 'requires';
            $rel = 'runtime';
        } elsif ($section =~ m!\A(?:os)?prereqs\s*/\s*(configure|build|test|runtime)(requires|recommends|suggests|conflicts)\z!i) {
            $phase = lc($1);
            $rel = lc($2);
        } else {
            next;
        }

        my $confsection = $confhash->{$section};
        for my $mod (sort keys %$confsection) {
            my $val = $confsection->{$mod};
            if ($mod eq '-phase') {
                $phase = $val;
                next;
            } elsif ($mod eq '-relationship') {
                $rel = $val;
                next;
            }
            $res->{$phase}{$rel}{$mod} = $confsection->{$mod};
        }
    }

    $res;
}

1;
# ABSTRACT:

=head1 SYNOPSIS

 use Dist::Zilla::Util::ParsePrereqsFromDistIni qw(parse_prereqs_from_dist_ini);

 my $prereqs = parse_prereqs_from_dist_ini(path => "dist.ini");

Sample result:

#CODE: require Dist::Zilla::Util::ParsePrereqsFromDistIni; Dist::Zilla::Util::ParsePrereqsFromDistIni::parse_prereqs_from_dist_ini(path => "dist.ini");


=head1 DESCRIPTION

This module provides C<parse_prereqs_from_dist_ini()>.


=head1 SEE ALSO

L<Dist::Zilla>
