package DVD::Read::Title;

use 5.010000;
use strict;
use warnings;

use DVD::Read;
use DVD::Read::Dvd::Ifo;
use AutoLoader;
use vars qw($AUTOLOAD);

our $VERSION = '0.01';

sub AUTOLOAD {
    my ($self, @args) = @_;
    my $sub = $AUTOLOAD;
    $sub =~ s/.*:://;
    if (exists(${DVD::Read::Dvd::Ifo::}{"vts_$sub"})) {
        $sub = "vts_$sub";
        return $self->_vts->$sub(@args);
    } elsif (exists(${DVD::Read::Dvd::Ifo::}{$sub}) && $sub =~ /^chapter_/) {
        my ($chapter) = (@args);
        $self->_vmg->$sub(
            $self->_vts,
            $self->_vmg->title_ttn($self->{titleid}),
            $chapter,
        );
    }
}

sub DESTROY {}

=head1 NAME

DVD::Read::Title - Fetch information from DVD video.

=head1 SYNOPSIS

  use DVD::Read::Title;
  my $title = DVD::Read::Title->new('/dev/cdrom', 1);
  print $title->video_format_txt . "\n";

=head1 DESCRIPTION

Fetch information from DVD video title.

=head1 FUNCTIONS

=head2 new($dvd, $title)

Return a new DVD::Read::Title object for $dvd and title number
$title.

$dvd can be either a string for IFO location, or a DVD::Read object.

=head2 chapter_first_sector($chapter)

Return the first sector for chapter number $chapter

=head2 chapter_last_sector($chapter)

Return the last sector for chapter number $chapter

=head2 chapter_offset($chapter)

Return the chapter offset from the start of title in millisecond

=cut

sub new {
    my ($class, $dvd, $title) = @_;

    my $dvdobj = ref $dvd
        ? $dvd
        : DVD::Read->new($dvd);

    my $self = bless({
        titleid => $title,
        dvd => $dvdobj,
        vts => undef,
    }, $class);

    $self->_vts or return;

    $dvdobj->{vts}[$title] = $self;
}

sub _dvd {
    my ($self) = @_;
    return $self->{dvd}
}

sub _vmg {
    my ($self) = @_;
    return $self->_dvd->_vmg;
}

sub _vts {
    my ($self) = @_;
    $self->_vmg or return;
    my $nr = $self->title_nr or return;
    return $self->{vts} ||=
        DVD::Read::Dvd::Ifo->new($self->_dvd->{dvd}, $nr);
}

=head2 length

The length in millisecond of this title.

=cut

sub length {
    my ($self) = @_;
    $self->_vmg or return;
    $self->_vmg->title_length(
        $self->_vts,
        $self->_vmg->title_ttn($self->{titleid}),
    );
}

=head2 chapters_count

Return the chapters count for this title

=cut

sub chapters_count {
    my ($self) = @_;
    $self->_vmg or return;
    $self->_vmg->title_chapters_count($self->{titleid});
}

=head2 title_nr

Return the real title number physically on dvd.

=cut

sub title_nr {
    my ($self) = @_;
    $self->_vmg or return;
    $self->_vmg->title_nr($self->{titleid});
}

=head1 AUTOLOADED FUNCTIONS

All functions from L<DVD::Read::Dvd::IFO> module starting by 'vts_'
are available (without 'vts_' prefix).

=cut

1;

__END__

=head1 CAVEAT

Most of C code come from mplayer and transcode (tcprobe).

Thanks authors of these modules to provide it as free software.

As this software are under another license, and this module reuse
code from it, the Perl license is maybe not appropriate.

Just mail me if this is a problem.

=head1 SEE ALSO

L<DVD::Read>
L<DVD::Read::Dvd::Ifo>

=head1 AUTHOR

Olivier Thauvin E<lt>nanardon@nanardon.zarb.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2008 by Olivier Thauvin

This module is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.

The libdvdread is under the GPL Licence.
