#!/bin/bash
# This script will call the routine as it is used by Brainy PIPES 
# for moving microscope data.
TIFF_PATH=$1
METADATA_PATH=$2
BRAINYDIR="$(dirname "$(dirname "${BASH_SOURCE[0]}")")/lib/python"
python - <<PYTHON
# Import iBRAIN environment.
import sys
import os
sys.path = [os.path.abspath('$BRAINYDIR')] + sys.path
from brainy.pipes.Tools import move_microscope_metadata

tiff_path = '$TIFF_PATH'
metadata_path = '$METADATA_PATH'
if not os.path.exists(metadata_path):
	os.mkdir(metadata_path)
assert os.path.exists(tiff_path)
move_microscope_metadata(tiff_path, metadata_path)

PYTHON
