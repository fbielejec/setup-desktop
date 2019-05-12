#!/bin/bash

sudo apt-get install -y caja-actions caja-dropbox

mv open-terminal-here /home/$USER/.config/caja/scripts/open-terminal-here
chmod +x /home/$USER/.config/caja/scripts/open-terminal-here

echo '(gtk_accel_path "<Actions>/ScriptsGroup/script_file:\\s\\s\\shome\\sfilip\\s.config\\scaja\\sscripts\\sopen-terminal-here" "<Primary><Shift>t")' >> /home/$USER//.config/caja/accels

cat /home/$USER//.config/caja/accels
