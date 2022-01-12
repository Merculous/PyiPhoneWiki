#!/usr/bin/env python3

import sys
import time
from urllib.error import HTTPError
from urllib.request import urlopen


def requestFromURL(url, read):
    name = 'requestFromURL'
    try:
        r = urlopen(url)
    except HTTPError as e:
        if e.code == 404:
            print(f'[{name}] {url} not found!')
        if e.code == 429:
            wait = int(e.headers['Request-After'])
            print(f'[{name}] server is asking to wait!')
            print(f'[{name}] waiting {wait:.4f} seconds...')
            time.sleep(wait)
    except ValueError:
        raise
    else:
        if not read:
            return r
        else:
            return r.read().decode()
    finally:
        print(f'[{name}] requesting from {url}')


class Wiki:
    def __init__(self):
        pass


def main(args):
    argc = len(args)


if __name__ == '__main__':
    main(tuple(sys.argv))
