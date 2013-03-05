#!/usr/bin/env python
'''
Lighten and Darken Projection script
(which is equivalent to maximum and minimum intensity projections)

http://www.imagemagick.org/Usage/compose/#lighten_intensity

Example:

find -name '*C02.png' | mip.py --infile - > ./C02MIP2.png

@note: 

 That result of this script should be equivalent to running:
 
  # Darken
  convert 1.png 2.png -background white -compose darken -mosaic result3.png
 
  #Lighten
  convert 1.png 2.png -background black -compose lighten -mosaic result3.png

or 

  convert $(find -name '*C02.png') -background black -compose lighten -mosaic result_mip.png

@todo:
 Known limitations
 - output file is always PNG
 - for now supports only grayscale (single channel) images
 - images must be of the same size
 - (optionally) read filenames from standard input

@author: Yauhen Yakimovich <yauhen.yakimovich@uzh.ch>
'''

# Extending lib path for iBRAIN environment.
import os
execfile(os.path.join(os.path.dirname(os.path.dirname(
    os.path.abspath(__file__))), 'lib', 'python','brainy',
    'extend_sys_path.py'))

import sys
import argparse
from functools import partial

from wand.image import Image
from wand.color import Color
from wand.display import display
from wand.api import library


PROJECTION_TYPES = 'max_intensity', 'min_intensity'


def project(projection, img, operator):
    '''
    Project image onto the projection using supplied (composition operator), 
    i.e. treat projection as base for img and save there the result.
    '''
    projection.composite(img, 0, 0, operator)


darken = partial(project, operator='darken')
darken.__doc__ = 'Darken the image eq. to minimum intensity projection'


lighten = partial(project, operator='lighten')
lighten.__doc__ = 'Lighten the image eq. to maximum intensity projection'


def project_files(filenames, projection_type, outfile):
    '''Project over multiple files'''
    # Prepare intensity projection output.
    projection = Image(filename=filenames.pop(0))     
    if projection_type == 'max_intesity':
        perform_projection = lighten        
    else:
        perform_projection = darken
    
    # Loop over list of files projecting them on previously predefined background.
    for img_filename in filenames:
        # print >> sys.stderr, 'Projecting ' + img_filename
        with Image(filename=img_filename) as img:
            if img.type != 'grayscale':
                img.type = 'grayscale'
            assert projection.size == img.size
            perform_projection(projection, img)
            
    
    # Save intensity projection as PNG.
    with projection.convert('png') as converted:
        converted.save(file=outfile)
    projection.close()


if __name__ == '__main__':
    
    parser = argparse.ArgumentParser('Maximum- and minimum intensity '
                                     'projections')
    parser.add_argument('--infile', metavar='file', type=argparse.FileType('r'),
                        dest='input_file',
                        help='Optional input text file containing image'
                        ' filenames. Use "--infile -" to read image filenames'
                        ' from standard input.')
    parser.add_argument('--outfile', nargs='?', type=argparse.FileType('w'),
                        default=sys.stdout, dest='output_file',
                        help='Output filename (by default standard output)')
    parser.add_argument('--type', dest='projection_type', default='max_intesity',
                        choices=PROJECTION_TYPES)
    parser.add_argument('image_filenames', nargs='*', type=str, 
                        help='List of image filenames that should be '
                        'projected.')
    args = parser.parse_args()
    image_filenames = args.image_filenames
    if len(image_filenames) == 0 and args.input_file is not None:
        # Try to read filenames from the input file.
        image_filenames = [filename.strip() for filename in args.input_file]        
    if len(image_filenames) < 2:
        print >> sys.stderr, 'Error, two or more images are expected.'
        parser.print_help()
        exit()
    # Check if all the images do exist.
    for filename in image_filenames:
        if os.path.exists(filename):
            continue        
        print >> sys.stderr, 'File not found: %s' % filename
        exit()

    # At this point we know arguments are correct
    project_files(image_filenames, args.projection_type, args.output_file)
