#!/bin/sh

APP=vlc

# DOWNLOADING THE DEPENDENCIES
wget https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage -O appimagetool
wget https://raw.githubusercontent.com/ivan-hc/AM-application-manager/main/tools/pkg2appimage
chmod a+x ./appimagetool ./pkg2appimage

# CREATING THE APPIMAGE: APPDIR FROM A RECIPE...
echo "app: vlc
binpatch: true

ingredients:
  dist: bionic
  sources:
    - deb http://archive.ubuntu.com/ubuntu/ bionic main universe restricted multiverse
    - deb http://archive.ubuntu.com/ubuntu bionic-security main universe restricted multiverse
    - deb http://archive.ubuntu.com/ubuntu/ bionic-updates main universe restricted multiverse
  ppas:
    - savoury1/ffmpeg4
    - savoury1/vlc3
    - savoury1/graphics
    - savoury1/multimedia
    - savoury1/build-tools
    - savoury1/backports
  packages:
    - vlc
    - vlc-l10n
    - vlc-plugin-video-output
    - x264
    - x265
    - libmatroska7
    - libplacebo192
    - libplacebo4" >> recipe.yml;

./pkg2appimage ./recipe.yml;

rm -R -f ./$APP/$APP.AppDir/vlc.desktop
echo "[Desktop Entry]
Version=1.0
Name=VLC media player
GenericName=Media player
Comment=Read, capture, broadcast your multimedia streams
Exec=vlc --started-from-file %U
TryExec=vlc
Icon=vlc
Terminal=false
Type=Application
Categories=AudioVideo;Player;Recorder;
MimeType=application/ogg;application/x-ogg;audio/ogg;audio/vorbis;audio/x-vorbis;audio/x-vorbis+ogg;video/ogg;video/x-ogm;video/x-ogm+ogg;video/x-theora+ogg;video/x-theora;audio/x-speex;audio/opus;application/x-flac;audio/flac;audio/x-flac;audio/x-ms-asf;audio/x-ms-asx;audio/x-ms-wax;audio/x-ms-wma;video/x-ms-asf;video/x-ms-asf-plugin;video/x-ms-asx;video/x-ms-wm;video/x-ms-wmv;video/x-ms-wmx;video/x-ms-wvx;video/x-msvideo;audio/x-pn-windows-acm;video/divx;video/msvideo;video/vnd.divx;video/avi;video/x-avi;application/vnd.rn-realmedia;application/vnd.rn-realmedia-vbr;audio/vnd.rn-realaudio;audio/x-pn-realaudio;audio/x-pn-realaudio-plugin;audio/x-real-audio;audio/x-realaudio;video/vnd.rn-realvideo;audio/mpeg;audio/mpg;audio/mp1;audio/mp2;audio/mp3;audio/x-mp1;audio/x-mp2;audio/x-mp3;audio/x-mpeg;audio/x-mpg;video/mp2t;video/mpeg;video/mpeg-system;video/x-mpeg;video/x-mpeg2;video/x-mpeg-system;application/mpeg4-iod;application/mpeg4-muxcodetable;application/x-extension-m4a;application/x-extension-mp4;audio/aac;audio/m4a;audio/mp4;audio/x-m4a;audio/x-aac;video/mp4;video/mp4v-es;video/x-m4v;application/x-quicktime-media-link;application/x-quicktimeplayer;video/quicktime;application/x-matroska;audio/x-matroska;video/x-matroska;video/webm;audio/webm;audio/3gpp;audio/3gpp2;audio/AMR;audio/AMR-WB;video/3gp;video/3gpp;video/3gpp2;x-scheme-handler/mms;x-scheme-handler/mmsh;x-scheme-handler/rtsp;x-scheme-handler/rtp;x-scheme-handler/rtmp;x-scheme-handler/icy;x-scheme-handler/icyx;application/x-cd-image;x-content/video-vcd;x-content/video-svcd;x-content/video-dvd;x-content/audio-cdda;x-content/audio-player;application/ram;application/xspf+xml;audio/mpegurl;audio/x-mpegurl;audio/scpls;audio/x-scpls;text/google-video-pointer;text/x-google-video-pointer;video/vnd.mpegurl;application/vnd.apple.mpegurl;application/vnd.ms-asf;application/vnd.ms-wpl;application/sdp;audio/dv;video/dv;audio/x-aiff;audio/x-pn-aiff;video/x-anim;video/x-nsv;video/fli;video/flv;video/x-flc;video/x-fli;video/x-flv;audio/wav;audio/x-pn-au;audio/x-pn-wav;audio/x-wav;audio/x-adpcm;audio/ac3;audio/eac3;audio/vnd.dts;audio/vnd.dts.hd;audio/vnd.dolby.heaac.1;audio/vnd.dolby.heaac.2;audio/vnd.dolby.mlp;audio/basic;audio/midi;audio/x-ape;audio/x-gsm;audio/x-musepack;audio/x-tta;audio/x-wavpack;audio/x-shorten;application/x-shockwave-flash;application/x-flash-video;misc/ultravox;image/vnd.rn-realpix;audio/x-it;audio/x-mod;audio/x-s3m;audio/x-xm;application/mxf;
X-KDE-Protocols=ftp,http,https,mms,rtmp,rtsp,sftp,smb
Keywords=Player;Capture;DVD;Audio;Video;Server;Broadcast;" >> ./$APP/$APP.AppDir/vlc.desktop

# ...DOWNLOADING LIBUNIONPRELOAD...
wget https://github.com/project-portable/libunionpreload/releases/download/amd64/libunionpreload.so
chmod a+x libunionpreload.so
mv ./libunionpreload.so ./$APP/$APP.AppDir/

# ...REPLACING THE EXISTING APPRUN WITH A CUSTOM ONE...
rm -R -f ./$APP/$APP.AppDir/AppRun
function1="'^Exec=.*'"
function2="'s|%.||g'"
echo '#!/bin/sh
HERE="$(dirname "$(readlink -f "${0}")")"
export UNION_PRELOAD="${HERE}"
export LD_PRELOAD="${HERE}/libunionpreload.so"
export PATH="${HERE}"/usr/bin/:"${HERE}"/usr/sbin/:"${HERE}"/usr/games/:"${HERE}"/bin/:"${HERE}"/opt/'$APP'/:"${HERE}"/sbin/:"${PATH}"
export LD_LIBRARY_PATH="${HERE}"/usr/lib/:"${HERE}"/usr/lib/'$APP'/:"${HERE}"/usr/lib64/'$APP'/:"${HERE}"/usr/lib32/'$APP'/:"${HERE}"/usr/lib/i386-linux-gnu/:"${HERE}"/usr/lib/x86_64-linux-gnu/:"${HERE}"/usr/lib32/:"${HERE}"/usr/lib64/:"${HERE}"/lib/:"${HERE}"/lib/i386-linux-gnu/:"${HERE}"/lib/x86_64-linux-gnu/:"${HERE}"/lib32/:"${HERE}"/lib64/:"${LD_LIBRARY_PATH}"
export PYTHONPATH="${HERE}"/usr/share/pyshared/:"${HERE}"/usr/lib/python*/:"${PYTHONPATH}"
export PYTHONHOME="${HERE}"/usr/:"${HERE}"/usr/lib/python*/
export XDG_DATA_DIRS="${HERE}"/usr/share/:"${HERE}"/usr/share/'$APP'/:"${XDG_DATA_DIRS}"
export PERLLIB="${HERE}"/usr/share/perl5/:"${HERE}"/usr/lib/perl5/:"${PERLLIB}"
export GSETTINGS_SCHEMA_DIR="${HERE}"/usr/share/glib-2.0/schemas/:"${GSETTINGS_SCHEMA_DIR}"
export QT_PLUGIN_PATH="${HERE}"/usr/lib/qt4/plugins/:"${HERE}"/usr/lib/'$APP'/:"${HERE}"/usr/lib64/'$APP'/:"${HERE}"/usr/lib32/'$APP'/:"${HERE}"/usr/lib/i386-linux-gnu/qt4/plugins/:"${HERE}"/usr/lib/x86_64-linux-gnu/qt4/plugins/:"${HERE}"/usr/lib32/qt4/plugins/:"${HERE}"/usr/lib64/qt4/plugins/:"${HERE}"/usr/lib/qt5/plugins/:"${HERE}"/usr/lib/i386-linux-gnu/qt5/plugins/:"${HERE}"/usr/lib/x86_64-linux-gnu/qt5/plugins/:"${HERE}"/usr/lib32/qt5/plugins/:"${HERE}"/usr/lib64/qt5/plugins/:"${QT_PLUGIN_PATH}"
EXEC=$(grep -e '$function1' "${HERE}"/*.desktop | head -n 1 | cut -d "=" -f 2- | sed -e '$function2')
exec ${EXEC} "$@"' >> AppRun
chmod a+x AppRun
mv ./AppRun ./$APP/$APP.AppDir

# ...IMPORT THE LAUNCHER AND THE ICON TO THE APPDIR (uncomment if not available)...
#cp ./$APP/$APP.AppDir/usr/share/icons/hicolor/22x22/apps/* ./$APP/$APP.AppDir/ 2>/dev/null
#cp ./$APP/$APP.AppDir/usr/share/icons/hicolor/24x24/apps/* ./$APP/$APP.AppDir/ 2>/dev/null
#cp ./$APP/$APP.AppDir/usr/share/icons/hicolor/32x32/apps/* ./$APP/$APP.AppDir/ 2>/dev/null
#cp ./$APP/$APP.AppDir/usr/share/icons/hicolor/48x48/apps/* ./$APP/$APP.AppDir/ 2>/dev/null
#cp ./$APP/$APP.AppDir/usr/share/icons/hicolor/64x64/apps/* ./$APP/$APP.AppDir/ 2>/dev/null
#cp ./$APP/$APP.AppDir/usr/share/icons/hicolor/128x128/apps/* ./$APP/$APP.AppDir/ 2>/dev/null
#cp ./$APP/$APP.AppDir/usr/share/icons/hicolor/256x256/apps/* ./$APP/$APP.AppDir/ 2>/dev/null
#cp ./$APP/$APP.AppDir/usr/share/icons/hicolor/512x512/apps/* ./$APP/$APP.AppDir/ 2>/dev/null
#cp ./$APP/$APP.AppDir/usr/share/icons/hicolor/scalable/apps/* ./$APP/$APP.AppDir/ 2>/dev/null
#cp ./$APP/$APP.AppDir/usr/share/applications/* ./$APP/$APP.AppDir/ 2>/dev/null

# ...EXPORT THE APPDIR TO AN APPIMAGE!
ARCH=x86_64 ./appimagetool -n ./$APP/$APP.AppDir;
underscore=_
mkdir version
mv ./$APP/$APP$underscore*.deb ./version/
version=$(ls ./version)

mv ./*.AppImage ./$(echo $version | rev| cut -c 5- | rev).AppImage
chmod a+x ./$(echo $version | rev| cut -c 5- | rev).AppImage