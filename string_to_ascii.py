#!/usr/bin/python

import sys

if len(sys.argv) >= 2:
    ascii_chars = [hex(ord(c)) for c in sys.argv[1]]
    print(' '.join(ascii_chars))
