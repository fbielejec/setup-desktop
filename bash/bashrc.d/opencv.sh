# OpenCV
#
# A hand-built tree under /opt/opencv/latest, not a packaged install — so the
# paths are absolute and exist only on a machine that actually built it.
# Guarded for that reason: without the check, every other machine prepends
# three non-existent directories to PATH, LD_LIBRARY_PATH and PKG_CONFIG_PATH,
# which is invisible until pkg-config or the loader starts behaving oddly.
_opencv_root=/opt/opencv/latest
if [ -d "$_opencv_root" ]; then
    export PATH="$_opencv_root/bin:$_opencv_root/release/bin:$PATH"
    export LD_LIBRARY_PATH="$_opencv_root/release/lib:$LD_LIBRARY_PATH"
    export PKG_CONFIG_PATH="$_opencv_root/lib/pkgconfig:$PKG_CONFIG_PATH"
    export OPENCV_TEST_DATA_PATH="$_opencv_root/opencv_extra-master/testdata"
fi
unset _opencv_root
