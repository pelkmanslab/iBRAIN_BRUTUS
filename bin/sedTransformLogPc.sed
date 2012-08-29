#!/bin/sed -f
s|<\([0-9]*\)>|\1|g
s|<\(ether.*\)>|\1|g
s|/BIOL/imsb/fs|\\\\nas-biol-imsb-1\\share-|g
s|/bio3/bio3/|-$\\|g
s|\([a-zA-Z0-9]\)/|\1\\|g
s| -- | - |g
s|-{4,}| - |g
s|text\\xsl|text/xsl|g
