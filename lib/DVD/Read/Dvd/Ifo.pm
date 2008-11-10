package DVD::Read::Dvd::Ifo;

use 5.010000;
use strict;
use warnings;

our $VERSION = '0.01';

require XSLoader;
XSLoader::load('DVD::Read', $VERSION);

=head1 NAME

DVD::Read::Dvd::Ifo - Access to DVD IFO file using libdvdread

=head1 SYNOPSIS

  use DVD::Read::Dvd;
  use DVD::Read::Dvd::Ifo;
  my $dvd = DVD::Read::Dvd->new('/dev/cdrom');
  my $vmg = DVD::Read::Dvd::Ifo->new($dvd, 0);
  ...

=head1 DESCRIPTION

This module provide a low level access DVD IFO files
using libdvdread.

This module allow you to get video titles informations
step by step like it is done by libdvdread.

Notice functions provided by module are really basics, then
you really need to understand the dvd information to use it.

=head1 GENERICS FUNCTIONS

=cut

=head2 new($dvd, $id)

Return a new DVD::Read::Dvd::Ifo:

=over 4

=item $dvd

A DVD::Read::Dvd object.

=item $id

The title number you want to get information.

If $id is 0, you'll get the VGM information.
Otherwise $id is normal given by title_nr function
from VGM DVD::Read::Dvd::Ifo object.

=back

=cut

=head1 VGM FUNCTIONS

This functions will work only for DVD::Read::Dvd::Ifo
object get from VGM table, eg title 0.

=head2 titles_count

Return the count of titles on the DVD

=head2 title_angles_count($title)

Get the angle count for title number $title

=head2 title_chapters_count($title)

Return the count of chapters for title number $title

=head2 title_nr($title)

Return the internal title id for title number $title.

The VGM provide the ordered list of title on DVD, which is usually
different of the physical order.

Here a real example to get title 1:

    my $vgm = DVD::Read::Dvd::Ifo($dvd, 0);
    my $titlenr = $vgm->title_nr(1);
    $chapter_count = $vgm->title_chapters_count($titlenr);
    my vts = DVD::Read::Dvd::Ifo($dvd, $titlenr);

    ...

=head2 title_ttn($title)

Return the ttn for title number $title.

I don't know what is the 'ttn', I just know it is need in some
other function. If you have explanation, mail me !

=head2 title_length($vts, $ttn)

Return the length in millisecond of title handle by $vts
DVD::Read::Dvd::Ifo object get from a title > 0.

=cut

=head2 chapter_offset($vts, $title, $chapter)

Return in millisecond the chapter offset from movie start of
chapter number $chapter of title number $title.

$vts is the DVD::Read::Dvd::Ifo object for title number $title.

It is unfriendly to have to give again the title number if the
VTS IFO is given. I haven't find another way, but remember this
module is low level access to dvdread API.

=head2 chapter_first_sector($vts, $title, $chapter)

Return first sector of chapter $chapter for title $title.

$vts is the DVD::Read::Dvd::Ifo object for title number $title.

=head2 chapter_last_sector($vts, $title, $chapter)

Return last sector of chapter $chapter for title $title.

$vts is the DVD::Read::Dvd::Ifo object for title number $title.

=cut

=head1 VTS FUNCTIONS

These function should be used over DVD::Read::Dvd::Ifo get
for title number highter than 0.

They are usually prefixed by 'vts_'.

=head2 vts_ttn_count

Return the count of ttn this title.

Again, I don't know what is the ttn...

=head2 vts_video_format

Return the video format

=head2 vts_video_format_txt

Return the video format in textual form

=cut

sub vts_video_format_txt {
    my ($self) = @_;
    defined(my $fmt = $self->vts_video_format) or return;
    return [ 'ntsc', 'pal' ]->[$fmt];
}

=head2 vts_video_size

Return the width and height of the video

=head2 vts_video_mpeg_version

Return the MPEG version used

=head2 vts_video_mpeg_version_txt

Return the MPEG version in textual form

=cut

sub vts_video_mpeg_version_txt {
    my ($self) = @_;
    defined(my $mpeg = $self->vts_video_mpeg_version) or return;
    'mpeg' . ($mpeg + 1)
}

=head2 vts_video_aspect_ratio

Return the aspect ratio

=head2 vts_video_aspect_ratio_txt

Return the aspect ratio in textual form

=cut

sub vts_video_aspect_ratio_txt {
    my ($self) = @_;
    defined(my $fmt = $self->vts_video_aspect_ratio) or return;
    return { 0 => '4:3', 3 => '16:9' }->{$fmt};
}

=head2 vts_video_permitted_df

Return the 'permitted_df' value, but no sure about
its meaning

=head2 vts_video_permitted_df_txt

Return the 'permitted_df' in textual form (from
transcode code).

=cut

sub vts_video_permitted_df_txt {
    my ($self) = @_;
    defined(my $fmt = $self->vts_video_permitted_df) or return;
    return [
        'pan&scan+letterboxed',
        'only pan&scan',
        'only letterboxed',
        '',
    ]->[$fmt];
}

=head2 vts_video_film_mode

Return true if the video is a movie

=head2 vts_video_letterboxed

Unknown meaning...

=head2 vts_video_line21_cc_1

Unknown meaning...

=head2 vts_video_line21_cc_2

Unknown meaning...

=head2 vts_video_ntsc_cc

Unknown meaning...

=cut

sub vts_video_ntsc_cc {
    my ($self) = @_;
    if($self->line21_cc_1 && $self->line21_cc_2) {
        return "NTSC CC 1 2";
    } elsif($self->line21_cc_1) {
        return "NTSC CC 1";
    } elsif($self->line21_cc_2) {
        return "NTSC CC 2";
    } else {
        return "";
    }
}

=head2 vts_audios

Return the list of existing audios tracks id

=head2 vts_audio_format($id)

Return the format of audio track number $id.

=head2 vts_audio_format_txt($id)

Return the format of audio track number $id
in textual form.

=cut

sub vts_audio_format_txt {
    my ($self, $audiono) = @_;
    defined(my $val = $self->vts_audio_format($audiono)) or return;
    return {
        0 => 'ac3',
        2 => 'mpeg layer 1/2/3',
        3 => 'mpeg2 ext',
        4 => 'lpcm',
        6 => 'dts',
    }->{$val}
}

=head2 vts_audio_frequency($id)

Return the frequency for audio track number $id.

=head2 vts_audio_frequency_txt($id)

Return the frequency for audio track number $id in textual form.

=cut

sub vts_audio_frequency_txt {
    my ($self, $audiono) = @_;
    defined(my $val = $self->vts_audio_frequency($audiono)) or return;
    return [
        '48kHz', '96kHz', '44.1kHz', '32kHz'
    ]->[$val];
}

=head2 vts_audio_language($id)

Return the language code for audio track number $id.

=head2 vts_audio_lang_extension($id)

Return the language extension for audio track number $id.
In fact this is comment about track content.

=head2 vts_audio_lang_extension_txt($id)

Return the language extension for audio track number $id
in textual form.

=cut

sub vts_audio_lang_extension_txt {
    my ($self, $audiono) = @_;
    $self->_lang_extension_txt($self->vts_audio_lang_extension($audiono));
}

=head2 vts_audio_quantization($id)

Not sure about the meaning, should the bit count
used to code sound.

=head2 vts_audio_quantization_txt($id)

Return audio quantization in textual form.

=cut

sub vts_audio_quantization_txt {
    my ($self, $audiono) = @_;
    defined(my $val = $self->vts_audio_quantization($audiono)) or return;
    return [
        '16bit', '20bit', '24bit', 'drc'
    ]->[$val];
}

=head2 vts_audio_channel($id)

Return the channel mode for audio track number $id.

=head2 vts_audio_channel_txt($id)

Return the channel mode for audio track number $id
in textual form.

=cut

sub vts_audio_channel_txt {
    my ($self, $audiono) = @_;
    defined(my $val = $self->vts_audio_channel($audiono)) or return;
    return [
        "mono", "stereo", "unknown", "unknown", 
        "5.1/6.1", "5.1"
    ]->[$val];
}

=head2 vts_audio_appmode($id)

The application mode for audio track number $id.
Eg, is the track for karaoke ?

=head2 vts_audio_appmode_txt($id)

The application mode for audio track number $id
in textual form.

=cut

sub vts_audio_appmode_txt {
    my ($self, $audiono) = @_;
    defined(my $val = $self->vts_audio_appmode($audiono)) or return;
    return [
        '', 'karaoke mode', 'surround sound mode', 
    ]->[$val];
}

=head2 vts_audio_multichannel_extension($id)

Does the audio track number $id has multichannel extension ?

=cut

=head2 vts_subtitles

Return the list of existing subtitles tracks id

=head2 vts_subtitle_language($id)

Return the language for subtitle $id.

=head2 vts_subtitle_lang_extension($id)

Return the language extension for susbtitle number $id.
This is in fact a comment about the subtitle content.

=head2 vts_subtitle_lang_extension_txt($id)

Return the language extension for susbtitle number $id
in textual form.

=cut

sub vts_subtitle_lang_extension_txt {
    my ($self, $subtitleno) = @_;
    $self->_lang_extension_txt($self->vts_audio_lang_extension($subtitleno));
}

sub _lang_extension_txt {
    my ($self, $code) = @_;
    defined($code) or return;
    return [
        '', 'Normal Caption', 'Audio for visually impaired',
        'Director\'s comments #1', 'Director\'s comments #2',
    ]->[$code];
}

1;
__END__

=head1 CAVEAT

Most of C code come from mplayer and transcode (tcprobe).

Thanks authors of these modules to provide it as free software.

As this software are under another license, and this module reuse
code from it, the Perl license is maybe not appropriate.

Just mail me if this is a problem.

=head1 SEE ALSO

L<DVD::Read::Dvd>

=head1 AUTHOR

Olivier Thauvin E<lt>nanardon@nanardon.zarb.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2008 by Olivier Thauvin

This module is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.

The libdvdread is under the GPL Licence.

=cut
