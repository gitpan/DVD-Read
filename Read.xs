#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include <dvdread/dvd_reader.h>
#include <dvdread/ifo_read.h>

#include "Read.h"

MODULE = DVD::Read		PACKAGE = DVD::Read		

MODULE = DVD::Read		PACKAGE = DVD::Read::Dvd

void
_new(class, device)
    char * class
    char * device
    PREINIT:
    dvd_reader_t * dvd;
    PPCODE:
    if ((dvd = DVDOpen(device)) != NULL)
       XPUSHs(sv_2mortal(sv_setref_pv(newSVpv("", 0), class, (void *)dvd)));
    else
        XSRETURN_UNDEF; 

char *
volid(dvd)
    dvd_reader_t * dvd
    PREINIT:
        char * volid = malloc(sizeof(char) * 33);
    PPCODE:
        if (DVDUDFVolumeInfo(dvd, volid, sizeof(volid), NULL, 0) >= 0 ||
            DVDISOVolumeInfo(dvd, volid, sizeof(volid), NULL, 0) >= 0)
            XPUSHs(sv_2mortal(newSVpv(volid, 0)));
        free(volid);
        
void
DESTROY(dvd)
    dvd_reader_t * dvd
    CODE:
    DVDClose(dvd);

MODULE = DVD::Read		PACKAGE = DVD::Read::Dvd::Ifo

void
new(class, dvd, titleno)
    char * class
    dvd_reader_t * dvd
    int titleno
    PREINIT:
    ifo_handle_t * ifo;
    PPCODE:
    if ((ifo = ifoOpen(dvd, titleno)))
        XPUSHs(sv_2mortal(sv_setref_pv(newSVpv("", 0), class, (void *)ifo)));
    else
        XSRETURN_UNDEF;

int
titles_count(ifo)
    ifo_handle_t * ifo
    CODE:
    if (ifo->tt_srpt)
        RETVAL = ifo->tt_srpt->nr_of_srpts;
    else
        RETVAL = 0;
    OUTPUT:
    RETVAL 

int
title_chapters_count(ifo, titleno)
    ifo_handle_t * ifo
    int titleno
    CODE:
    if (ifo->tt_srpt && titleno <= ifo->tt_srpt->nr_of_srpts)
        RETVAL = ifo->tt_srpt->title[titleno -1].nr_of_ptts;
    else
        RETVAL = 0;
    OUTPUT:
    RETVAL

int
title_angles_count(ifo, titleno)
    ifo_handle_t * ifo
    int titleno
    CODE:
    if (ifo->tt_srpt && titleno <= ifo->tt_srpt->nr_of_srpts)
        RETVAL = ifo->tt_srpt->title[titleno -1].nr_of_angles;
    else
        RETVAL = 0;
    OUTPUT:
    RETVAL

int
title_nr(ifo, titleno)
    ifo_handle_t * ifo
    int titleno
    CODE:
    if (ifo->tt_srpt && titleno <= ifo->tt_srpt->nr_of_srpts)
        RETVAL = ifo->tt_srpt->title[titleno -1].title_set_nr;
    else
        RETVAL = 0;
    OUTPUT:
    RETVAL

int
title_ttn(ifo, titleno)
    ifo_handle_t * ifo
    int titleno
    CODE:
    if (ifo->tt_srpt && titleno <= ifo->tt_srpt->nr_of_srpts)
        RETVAL = ifo->tt_srpt->title[titleno -1].vts_ttn;
    else
        RETVAL = 0;
    OUTPUT:
    RETVAL

# FROM VTS 

void
vts_video_mpeg_version(ifo)
    ifo_handle_t * ifo
    PREINIT:
    video_attr_t *attr;
    PPCODE:
    if (ifo->vtsi_mat) {
        attr = &ifo->vtsi_mat->vts_video_attr;
        XPUSHs(sv_2mortal(newSViv(attr->mpeg_version)));
    }

void
vts_video_format(ifo)
    ifo_handle_t * ifo
    PREINIT:
    video_attr_t *attr;
    PPCODE:
    if (ifo->vtsi_mat) {
        attr = &ifo->vtsi_mat->vts_video_attr;
        XPUSHs(sv_2mortal(newSViv(attr->video_format)));
    }

void
vts_video_aspect_ratio(ifo)
    ifo_handle_t * ifo
    PREINIT:
    video_attr_t *attr;
    PPCODE:
    if (ifo->vtsi_mat) {
        attr = &ifo->vtsi_mat->vts_video_attr;
        XPUSHs(sv_2mortal(newSViv(attr->display_aspect_ratio)));
    }

void
vts_video_permitted_df(ifo)
    ifo_handle_t * ifo
    PREINIT:
    video_attr_t *attr;
    PPCODE:
    if (ifo->vtsi_mat) {
        attr = &ifo->vtsi_mat->vts_video_attr;
        XPUSHs(sv_2mortal(newSViv(attr->permitted_df)));
    }

void
vts_video_line21_cc_1(ifo)
    ifo_handle_t * ifo
    PREINIT:
    video_attr_t *attr;
    PPCODE:
    if (ifo->vtsi_mat) {
        attr = &ifo->vtsi_mat->vts_video_attr;
        XPUSHs(sv_2mortal(newSViv(attr->line21_cc_1)));
    }

void
vts_video_line21_cc_2(ifo)
    ifo_handle_t * ifo
    PREINIT:
    video_attr_t *attr;
    PPCODE:
    if (ifo->vtsi_mat) {
        attr = &ifo->vtsi_mat->vts_video_attr;
        XPUSHs(sv_2mortal(newSViv(attr->line21_cc_2)));
    }

void
vts_video_letterboxed(ifo)
    ifo_handle_t * ifo
    PREINIT:
    video_attr_t *attr;
    PPCODE:
    if (ifo->vtsi_mat) {
        attr = &ifo->vtsi_mat->vts_video_attr;
        XPUSHs(sv_2mortal(newSViv(attr->letterboxed)));
    }

void
vts_video_film_mode(ifo)
    ifo_handle_t * ifo
    PREINIT:
    video_attr_t *attr;
    PPCODE:
    if (ifo->vtsi_mat) {
        attr = &ifo->vtsi_mat->vts_video_attr;
        XPUSHs(sv_2mortal(newSViv(attr->film_mode)));
    }

void
vts_video_size(ifo)
    ifo_handle_t * ifo
    PREINIT:
    video_attr_t *attr;
    PPCODE:
    if (ifo->vtsi_mat) {
        int height = 480;
        attr = &ifo->vtsi_mat->vts_video_attr;
        if(attr->video_format != 0)
          height = 576;
        switch(attr->picture_size) {
        case 0:
          XPUSHs(sv_2mortal(newSViv(720)));
          break;
        case 1:
          XPUSHs(sv_2mortal(newSViv(704)));
          break;
        case 2:
          XPUSHs(sv_2mortal(newSViv(352)));
          break;
        case 3:
          XPUSHs(sv_2mortal(newSViv(352)));
          height =  height/2;
          break;
        default:
          break;
        }
        XPUSHs(sv_2mortal(newSViv(height)));
    }

int
vts_ttn_count(ifo)
    ifo_handle_t * ifo
    CODE:
    if (ifo->vts_pgcit)
        RETVAL=ifo->vts_pgcit->nr_of_pgci_srp;
    else RETVAL = 0;
    OUTPUT:
    RETVAL

void
vts_audios(ifo)
    ifo_handle_t * ifo
    PREINIT:
    pgc_t *pgc = NULL;
    int i;
    audio_attr_t   *a_attr;
    PPCODE:
    if (ifo->vtsi_mat)
    for (i = 0; i < ifo->vtsi_mat->nr_of_vts_audio_streams; i++) {
        a_attr = &ifo->vtsi_mat->vts_audio_attr[i];
        if(!(  a_attr->audio_format == 0
            && a_attr->multichannel_extension == 0
            && a_attr->lang_type == 0
            && a_attr->application_mode == 0
            && a_attr->quantization == 0
            && a_attr->sample_frequency == 0
            && a_attr->channels == 0
            && a_attr->lang_extension == 0
            && a_attr->unknown1 == 0
            && a_attr->unknown1 == 0))
            XPUSHs(sv_2mortal(newSViv(i)));
    }

void
vts_audio_language(ifo, audiono)
    ifo_handle_t * ifo
    int audiono
    PREINIT:
    audio_attr_t   *a_attr;
    PPCODE:
    if (ifo->vtsi_mat)
    if (audiono < ifo->vtsi_mat->nr_of_vts_audio_streams) {
        a_attr = &ifo->vtsi_mat->vts_audio_attr[audiono];
        if(a_attr->lang_type == 1) {
            char tmp[3] = "";
            tmp[0]=a_attr->lang_code>>8;
            tmp[1]=a_attr->lang_code&0xff;
            tmp[2]=0;
            XPUSHs(sv_2mortal(newSVpv(tmp, 0)));
        }
    }

void
vts_audio_format(ifo, audiono)
    ifo_handle_t * ifo
    int audiono
    PREINIT:
    audio_attr_t   *a_attr;
    PPCODE:
    if (ifo->vtsi_mat)
    if (audiono < ifo->vtsi_mat->nr_of_vts_audio_streams) {
        a_attr = &ifo->vtsi_mat->vts_audio_attr[audiono];
        XPUSHs(sv_2mortal(newSViv(a_attr->audio_format)));
    }

void
vts_audio_channel(ifo, audiono)
    ifo_handle_t * ifo
    int audiono
    PREINIT:
    audio_attr_t   *a_attr;
    PPCODE:
    if (ifo->vtsi_mat)
    if (audiono < ifo->vtsi_mat->nr_of_vts_audio_streams) {
        a_attr = &ifo->vtsi_mat->vts_audio_attr[audiono];
        XPUSHs(sv_2mortal(newSViv(a_attr->channels)));
    }

void
vts_audio_appmode(ifo, audiono)
    ifo_handle_t * ifo
    int audiono
    PREINIT:
    audio_attr_t   *a_attr;
    PPCODE:
    if (ifo->vtsi_mat)
    if (audiono < ifo->vtsi_mat->nr_of_vts_audio_streams) {
        a_attr = &ifo->vtsi_mat->vts_audio_attr[audiono];
        XPUSHs(sv_2mortal(newSViv(a_attr->application_mode)));
    }

void
vts_audio_quantization(ifo, audiono)
    ifo_handle_t * ifo
    int audiono
    PREINIT:
    audio_attr_t   *a_attr;
    PPCODE:
    if (ifo->vtsi_mat)
    if (audiono < ifo->vtsi_mat->nr_of_vts_audio_streams) {
        a_attr = &ifo->vtsi_mat->vts_audio_attr[audiono];
        XPUSHs(sv_2mortal(newSViv(a_attr->quantization)));
    }

void
vts_audio_frequency(ifo, audiono)
    ifo_handle_t * ifo
    int audiono
    PREINIT:
    audio_attr_t   *a_attr;
    PPCODE:
    if (ifo->vtsi_mat)
    if (audiono < ifo->vtsi_mat->nr_of_vts_audio_streams) {
        a_attr = &ifo->vtsi_mat->vts_audio_attr[audiono];
        XPUSHs(sv_2mortal(newSViv(a_attr->sample_frequency)));
    }

void
vts_audio_lang_extension(ifo, audiono)
    ifo_handle_t * ifo
    int audiono
    PREINIT:
    audio_attr_t   *a_attr;
    PPCODE:
    if (ifo->vtsi_mat)
    if (audiono < ifo->vtsi_mat->nr_of_vts_audio_streams) {
        a_attr = &ifo->vtsi_mat->vts_audio_attr[audiono];
        XPUSHs(sv_2mortal(newSViv(a_attr->lang_extension)));
    }

void
vts_audio_multichannel_extension(ifo, audiono)
    ifo_handle_t * ifo
    int audiono
    PREINIT:
    audio_attr_t   *a_attr;
    PPCODE:
    if (ifo->vtsi_mat)
    if (audiono < ifo->vtsi_mat->nr_of_vts_audio_streams) {
        a_attr = &ifo->vtsi_mat->vts_audio_attr[audiono];
        XPUSHs(sv_2mortal(newSViv(a_attr->multichannel_extension)));
    }


void
vts_subtitles(ifo)
    ifo_handle_t * ifo
    PREINIT:
    int i;
    subp_attr_t    *s_attr;
    PPCODE:
    if (ifo->vtsi_mat)
    for (i = 0; i < ifo->vtsi_mat->nr_of_vts_subp_streams; i++) {
        s_attr = &ifo->vtsi_mat->vts_subp_attr[i];
        if (!(  s_attr->type == 0
             && s_attr->zero1 == 0
             && s_attr->lang_code == 0
             && s_attr->lang_extension == 0
             && s_attr->zero2 == 0))
            XPUSHs(sv_2mortal(newSViv(i)));
    }

void
vts_subtitle_lang_extension(ifo, subtitleno)
    ifo_handle_t * ifo
    int subtitleno
    PREINIT:
    subp_attr_t    *s_attr;
    PPCODE:
    if (ifo->vtsi_mat)
    if (subtitleno < ifo->vtsi_mat->nr_of_vts_subp_streams) {
        s_attr = &ifo->vtsi_mat->vts_subp_attr[subtitleno];
        XPUSHs(sv_2mortal(newSViv(s_attr->lang_extension)));
    }
        
void
vts_subtitle_language(ifo, subtitleno)
    ifo_handle_t * ifo
    int subtitleno
    PREINIT:
    subp_attr_t    *s_attr;
    PPCODE:
    if (ifo->vtsi_mat)
    if (subtitleno < ifo->vtsi_mat->nr_of_vts_subp_streams) {
        s_attr = &ifo->vtsi_mat->vts_subp_attr[subtitleno];
        if(s_attr->type == 1) {
            char tmp[3] = "";
            tmp[0]=s_attr->lang_code>>8;
            tmp[1]=s_attr->lang_code&0xff;
            tmp[2]=0;
            XPUSHs(sv_2mortal(newSVpv(tmp, 0)));
        }
    }

# chapter discovering, woot

void
title_length(vmg, vts, ttn)
    ifo_handle_t * vmg
    ifo_handle_t * vts
    int ttn
    PREINIT:
    pgc_t *cur_pgc;
    int pgc_id;
    tt_srpt_t *tt_srpt;
    vts_ptt_srpt_t * vts_ptt_srpt;
    dvd_time_t     *dt;
    long ms, hour, minute, second;
    double fps;
    PPCODE:
    tt_srpt = vmg->tt_srpt;
    vts_ptt_srpt = vts->vts_ptt_srpt;
    if (tt_srpt && vts_ptt_srpt)
    if (ttn <= tt_srpt->nr_of_srpts) {
        pgc_id   = vts_ptt_srpt->title[ttn - 1].ptt[0].pgcn;
        cur_pgc  = vts->vts_pgcit->pgci_srp[pgc_id - 1].pgc;
        dt = &cur_pgc->playback_time;
        hour = ((dt->hour & 0xf0) >> 4) * 10 + (dt->hour & 0x0f);
        minute = ((dt->minute & 0xf0) >> 4) * 10 + (dt->minute & 0x0f);
        second = ((dt->second & 0xf0) >> 4) * 10 + (dt->second & 0x0f);
        if (((dt->frame_u & 0xc0) >> 6) == 1)
            fps = 25.00;
        else
            fps = 29.97;
        dt->frame_u &= 0x3f;
        dt->frame_u = ((dt->frame_u & 0xf0) >> 4) * 10 + (dt->frame_u & 0x0f);
        ms = (double)dt->frame_u * 1000.0 / fps;

        XPUSHs(sv_2mortal(newSViv(
            hour * 60 * 60 * 1000 + minute * 60 * 1000 + second * 1000 + ms
        )));
    }

void
chapter_first_sector(vmg, vts, ttn, chapter)
    ifo_handle_t * vmg
    ifo_handle_t * vts
    int ttn
    int chapter
    PREINIT:
    pgc_t *cur_pgc;
    int pgc_id;
    tt_srpt_t *tt_srpt;
    vts_ptt_srpt_t * vts_ptt_srpt;
    PPCODE:
    chapter--;
    tt_srpt = vmg->tt_srpt;
    vts_ptt_srpt = vts->vts_ptt_srpt;
    if (tt_srpt && vts_ptt_srpt)
    if (ttn <= tt_srpt->nr_of_srpts) {
        pgc_id   = vts_ptt_srpt->title[ttn - 1].ptt[chapter].pgcn;
        cur_pgc  = vts->vts_pgcit->pgci_srp[pgc_id - 1].pgc;
        XPUSHs(sv_2mortal(newSViv(cur_pgc->cell_playback[chapter].first_sector)));
    }

void
chapter_last_sector(vmg, vts, ttn, chapter)
    ifo_handle_t * vmg
    ifo_handle_t * vts
    int ttn
    int chapter
    PREINIT:
    pgc_t *cur_pgc;
    int pgc_id;
    tt_srpt_t *tt_srpt;
    vts_ptt_srpt_t * vts_ptt_srpt;
    PPCODE:
    chapter--;
    tt_srpt = vmg->tt_srpt;
    vts_ptt_srpt = vts->vts_ptt_srpt;
    if (tt_srpt && vts_ptt_srpt)
    if (ttn <= tt_srpt->nr_of_srpts) {
        pgc_id   = vts_ptt_srpt->title[ttn - 1].ptt[chapter].pgcn;
        cur_pgc  = vts->vts_pgcit->pgci_srp[pgc_id - 1].pgc;
        XPUSHs(sv_2mortal(newSViv(cur_pgc->cell_playback[chapter].last_sector)));
    }

void
chapter_offset(vmg, vts, ttn, chapter)
    ifo_handle_t * vmg
    ifo_handle_t * vts
    int ttn
    int chapter
    PREINIT:
    pgc_t *cur_pgc;
    int pgn, pgc_id, start_cell, end_cell, j, i;
    dvd_time_t     *dt;
    double          fps;
    long            hour, minute, second, ms, overall_time, cur_time, playtime;
    tt_srpt_t *tt_srpt;
    vts_ptt_srpt_t * vts_ptt_srpt;
    PPCODE:
    tt_srpt = vmg->tt_srpt;
    vts_ptt_srpt = vts->vts_ptt_srpt;
    chapter--; /* 1 => 0 */
    if (tt_srpt && vts_ptt_srpt)
    if (ttn <= tt_srpt->nr_of_srpts) {
        cur_time   = 0;
        for(i=0;i<chapter;i++) {
        pgc_id   = vts_ptt_srpt->title[ttn - 1].ptt[i].pgcn;
        pgn      = vts_ptt_srpt->title[ttn - 1].ptt[i].pgn;
        cur_pgc  = vts->vts_pgcit->pgci_srp[pgc_id -1].pgc;
        start_cell = cur_pgc->program_map[pgn - 1] - 1;

        pgc_id   = vts_ptt_srpt->title[ttn - 1].ptt[i+1].pgcn;
        pgn      = vts_ptt_srpt->title[ttn - 1].ptt[i+1].pgn;
        cur_pgc  = vts->vts_pgcit->pgci_srp[pgc_id -1].pgc;
        end_cell = cur_pgc->program_map[pgn - 1] - 2;

        for(j=start_cell;j<=end_cell;j++) {
            dt = &cur_pgc->cell_playback[j].playback_time;
            hour = ((dt->hour & 0xf0) >> 4) * 10 + (dt->hour & 0x0f);
            minute = ((dt->minute & 0xf0) >> 4) * 10 + (dt->minute & 0x0f);
            second = ((dt->second & 0xf0) >> 4) * 10 + (dt->second & 0x0f);
            if (((dt->frame_u & 0xc0) >> 6) == 1)
                fps = 25.00;
            else
                fps = 29.97;
            dt->frame_u &= 0x3f;
            dt->frame_u = ((dt->frame_u & 0xf0) >> 4) * 10 + (dt->frame_u & 0x0f);
            ms = (double)dt->frame_u * 1000.0 / fps;
            cur_time += (hour * 60 * 60 * 1000 + minute * 60 * 1000 + second * 1000 + ms);
        }
        }
        XPUSHs(sv_2mortal(newSViv(cur_time)));
    }

void
DESTROY(ifo)
    ifo_handle_t * ifo
    CODE:
    ifoClose(ifo);
