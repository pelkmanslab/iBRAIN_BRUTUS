import os
import sys


d = os.path.dirname
sys.path = [os.path.join(d(d(os.path.abspath(__file__))),
        'lib', 'python')] + sys.path
del d

