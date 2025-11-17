#!/bin/bash
cd /home/tristen/.local/share/VCV/Rack2Pro/ || exit
exec pw-jack ./Rack "$@"
