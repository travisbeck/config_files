#!/usr/bin/env python

import os, re, errno
from fnmatch import fnmatch


def file_list(directory):
    all_files = []

    ignores = []
    ignore_file = open(os.path.join(directory, '.ignore_files'))
    for line in ignore_file.read().splitlines():
        ignores.append(line)

    ignore_file = open(os.path.join(directory, '.gitignore'))
    for line in ignore_file.read().splitlines():
        ignores.append(line)

    # add the trailing slash if it doesn't already exist
    directory = os.path.join(directory, '')

    for root, dirs, files in os.walk(directory):
        # filter out files we want to ignore
        for ignore in ignores:
            files = [n for n in files if not fnmatch(n, ignore)]
            dirs[:] = [d for d in dirs if not fnmatch(d, ignore)]

        for file in files:
            path = re.sub(directory, '', os.path.join(root, file))
            all_files.append(path)

    return all_files

def create_link(source, target):
    print "linking %s -> %s" % (target, source)
    dir, file = os.path.split(target)
    if not os.path.isdir(dir):
        try:
            os.makedirs(dir)
        except OSError as exc:
            if exc.errno == errno.EEXIST and os.path.isdir(target_path):
                pass
            else:
                raise

    os.symlink(source, target)

def copy_content(source, target):
    source_file = open(source)
    source_content = source_file.read()
    target_file = open(target)
    target_content = target_file.read()

    if source_content != target_content:
        print "copying content from %s to %s" % (source, target)
        target_file = open(target, 'w')
        target_file.write(source_content)
    else:
        print "files are the same: %s %s" % (source, target)

def fix_link(source, target):
    print "fixing link %s -> %s" % (target, source)
    os.unlink(target)
    os.symlink(source, target)

if __name__ == "__main__":
    repo_dir = os.path.abspath('./')
    target_dir = os.environ['HOME']

    for filepath in file_list(repo_dir):
        source_path = os.path.join(repo_dir, filepath)
        target_path = os.path.join(target_dir, filepath)

        if not os.path.lexists(target_path):
            # create the link if there is no file or link
            create_link(source_path, target_path)
        elif os.path.islink(target_path):
            if not os.path.exists(os.readlink(target_path)):
                # fix the link if it is a link but doesn't point to the right place
                fix_link(source_path, target_path)
            else:
                # default normal case
                pass
        else:
            # it's a file and should be copied to the repo and replaced with a symlink
            copy_content(target_path, source_path)
            fix_link(source_path, target_path)
