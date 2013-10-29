import os
import sys


already_extended = False
ROOT = 'iBRAIN'


def get_root_path(module_path, root=ROOT, readlink=False):
    if module_path.endswith('.py'):
        if readlink and os.path.islink(module_path):
            module_path = os.readlink(module_path)
        # module_path points to a symlink
        module_path = os.path.abspath(module_path)
        root_path = os.path.dirname(module_path)
    elif module_path.endswith('.pyc'):
        # module_path points to .pyc
        module_path = os.path.abspath(module_path)
        root_path, module_path = module_path.rsplit(root + '/', 1)
        root_path += ROOT
    else:
        print module_path
        raise Exception('Failed to set root path')
    return root_path


def extend_sys_path(module_path, folders):
    global already_extended
    if already_extended:
        return
    root_path = get_root_path(module_path)
    for folder in folders:
        # Prepend path to the modules effectively prioritizing them.
        sys.path.insert(0, os.path.join(root_path, folder))
    already_extended = True


extend_sys_path(__file__, ['lib/python'])
