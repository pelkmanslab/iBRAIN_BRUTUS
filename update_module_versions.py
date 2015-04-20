#!/usr/bin/env python
'''
Update module_versions.txt file.

'''
import os
from sh import git

ROOT = os.path.abspath(os.path.dirname(__file__))


def get_module_tags(path):
    os.chdir(path)
    res = git.tag('--points-at', 'HEAD')
    assert res.exit_code == 0
    lines = res.stdout.split('\n')
    return lines[0]


if __name__ == '__main__':
    # Pull latest tags.
    os.system('git submodule foreach \'git fetch --tags\'')
    # Assume every module is in correct state.
    module_paths = [
        os.path.join(ROOT, 'tools', 'CellProfilerPelkmans'),
        os.path.join(ROOT, 'tools', 'PelkmansLibrary'),
        os.path.join(ROOT, 'tools', 'iBRAINShared'),
    ]
    versions_path = os.path.join(ROOT, 'versions.txt')
    with open(versions_path, 'w+') as versions:
        for module_path in module_paths:
            module_name = os.path.basename(module_path)
            module_tags = get_module_tags(module_path)
            versions.write('%s %s\n' % (module_name, module_tags))
