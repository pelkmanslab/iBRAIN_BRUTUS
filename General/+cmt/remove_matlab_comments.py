#!/usr/bin/env python

import os
import sys
import re


is_comment = re.compile(r'^\s*\%', re.M)


def has_a_comment(line):
    return bool(is_comment.search(line))


def remove_comments(matlab_file):
    result = list()
    for line in matlab_file:
        if has_a_comment(line):
            continue
        result.append(line.rstrip())
    return result


#if has_a_comment(' % this is a matlab comment'):
#    print 'yes'

if __name__ == '__main__':
    matlab_file = [line for line in open(sys.argv[1])]
    cleaned = remove_comments(matlab_file)
    output = open(sys.argv[2], 'w+')
    output.write('\n'.join(cleaned))
    output.close()
