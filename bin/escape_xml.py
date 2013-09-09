#!/usr/bin/python
import sys
from xml.sax.saxutils import escape


input = sys.stdin.read()
sys.stdout.write(escape(input))
