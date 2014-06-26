import re
from xml.sax.saxutils import escape as escape_xml
from subprocess import (PIPE, Popen)


# http://www.w3.org/TR/REC-xml/#charsets
escape_exp = re.compile('/[^\x0009\x000a\x000d\x0020-\xD7FF\xE000'
                        '-\xFFFD]+/u')


def invoke(command, _in=None):
    '''
    Invoke command as a new system process and return its output.
    '''
    process = Popen(command, stdin=PIPE, stdout=PIPE, shell=True,
                    executable='/bin/bash')
    if _in is not None:
        process.stdin.write(_in)
    return process.stdout.read()


def escape_xml_cdata(raw_value):
    return escape_exp.sub('', raw_value)
