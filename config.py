#!/usr/local/bin/python

import __builtin__

def setup_vprint(verbose):
    if verbose:
        def vprint(*args):
            # Print each argument separately so caller doesn't need to
            # stuff everything to be printed into a single string
            for arg in args:
               print arg,
            print
    else:
        vprint = lambda *a: None      # do-nothing function
    __builtin__.vprint = vprint

setup_vprint(False)
