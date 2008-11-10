use strict;
use Test::More tests => 46;
BEGIN { use_ok('DVD::Read::Dvd') };
BEGIN { use_ok('DVD::Read::Dvd::Ifo') };

my $testdir = 'tdvd';

{ # start with shadock, cd n°1

ok(my $dvd = DVD::Read::Dvd->new("$testdir/shadok1"), "can open dvd");
ok(my $ifo = DVD::Read::Dvd::Ifo->new($dvd, 0), "can get main ifo");
is($ifo->titles_count, 9, "can get title count");
is($ifo->title_nr(1), 1, "Can get title nr");
is(my $ttn = $ifo->title_ttn(1), 1, "Can get ttn");

ok(my $vtsifo = DVD::Read::Dvd::Ifo->new($dvd, 1), "can get ifo 1");
is($vtsifo->vts_video_mpeg_version, 1, 'can get video mpeg version');
is($vtsifo->vts_video_mpeg_version_txt, 'mpeg2', 'can get video mpeg version (txt)');
is($vtsifo->vts_video_format, 1, 'can get video format');
is($vtsifo->vts_video_format_txt, 'pal', 'can get video format (txt)');
is($vtsifo->vts_video_aspect_ratio, 0, 'can get video aspect ratio');
is($vtsifo->vts_video_aspect_ratio_txt, '4:3', 'can get video aspect ratio (txt)');
my @size = $vtsifo->vts_video_size();
is($size[0], '720', "can get width");
is($size[1], '576', "can get height");
my @audios = $vtsifo->vts_audios();
is(scalar(@audios), 1, "can get audio count");
ok(!$vtsifo->vts_audio_language(0), "vts_audio_language(), but no lang defined here");
is($vtsifo->vts_audio_format(0), 4, "audio format is 4 (lpcm)");
is($vtsifo->vts_audio_format_txt(0), 'lpcm', "audio format lpcm (txt)");
is($vtsifo->vts_audio_channel(0), 1, "audio channel is 1 (stereo)");
is($vtsifo->vts_audio_channel_txt(0), 'stereo', "audio channel stereo (txt)");
is($vtsifo->vts_audio_appmode(0), 0, "application mode is 0 (unspecified)");
is($vtsifo->vts_audio_appmode_txt(0), '', "application mode '' (txt)");
is($vtsifo->vts_audio_frequency(0), 0, "frequency is 0 (48kHz')");
is($vtsifo->vts_audio_frequency_txt(0), '48kHz', "frequency '48kHz' (txt)");
is($vtsifo->vts_audio_quantization(0), 0, "quantization is 0 (16bit)");
is($vtsifo->vts_audio_quantization_txt(0), '16bit', "quantization '16bit' (txt)");
is($vtsifo->vts_audio_lang_extension(0), 0, "lang_extension is 0 (unspecified)");
is(
    $vtsifo->vts_audio_lang_extension_txt(0), '', 
    "lang_extension '' (txt)"
);
is($vtsifo->vts_audio_multichannel_extension(0), 0, "multichannel_extension (No)");
}

{ # shadok don't have subtitle, let continue with another wonderfull
  # movie: idiocracy
ok(my $dvd = DVD::Read::Dvd->new("$testdir/idiocracy"), "can open dvd");
ok(my $ifo = DVD::Read::Dvd::Ifo->new($dvd, 0), "can get main ifo");
is(my $ttn = $ifo->title_ttn(1), 1, "Can get ttn");
is($ifo->title_nr(1), 5, "Can get title nr");

ok(my $vtsifo = DVD::Read::Dvd::Ifo->new($dvd, 5), "can get ifo 1");
is($vtsifo->vts_audio_language(0), 'en', "audio(0) language is en");
my @subtitles = $vtsifo->vts_subtitles();
is(scalar(@subtitles), 4, "can get subtitle count");
is($vtsifo->vts_subtitle_language(0), 'en', "subtitle(0) language is en");
is($vtsifo->vts_subtitle_lang_extension(0), 0, "lang_extension is 0 (unspecified)");
is(
    $vtsifo->vts_subtitle_lang_extension_txt(0), '', 
    "lang_extension '' (txt)"
);

is($ifo->chapter_first_sector($vtsifo, $ttn, 2), 78148, "can get first sector");
is($ifo->chapter_last_sector($vtsifo, $ttn, 2), 145124, "can get last sector");
is($ifo->chapter_last_sector($vtsifo, $ttn, 21), 1334794, "can get last sector");
is($ifo->chapter_offset($vtsifo, $ttn, 2), 203_000, "can get duration");
is($ifo->title_length($vtsifo, $ttn), 5_047_300, "Can get title lenght");
}
