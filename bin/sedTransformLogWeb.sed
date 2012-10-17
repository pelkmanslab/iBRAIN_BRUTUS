#!/bin/sed -f
s|<\([0-9]*\)>|\1|g
s|<\(ether.*\)>|\1|g
s|<\(beta.*\)>|\1|g
s|<\(qsnet.*\)>|\1|g
s|<\(vip.*\)>|\1|g
s|<\(pub.*\)>|\1|g
