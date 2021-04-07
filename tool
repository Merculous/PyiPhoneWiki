#!/usr/bin/env python3

from os import O_NOFOLLOW
import sys
from argparse import ArgumentParser

from mwclient import Site


class Wiki:
    def __init__(self) -> None:
        self.site = Site('theiphonewiki.com')
        self.devices = {
            'Apple TV': [],
            'iPad': [],
            'iPhone': [],
            'iPod': []
        }

    def getAllDevices(self) -> None:
        category = self.site.categories['Devices']
        for page in category:
            name = page.name
            if name.startswith('List'):
                for device in self.devices:
                    if device in name:
                        stuff = page.text().splitlines()
                        for device_name in stuff:
                            stop = 'Internal Name: '
                            if stop in device_name:
                                device_name = device_name.split(stop)
                                if 'code' in device_name[1]:
                                    device_name = device_name[1].replace(
                                        '<code>', '').replace('</code>', '')

                                if 'AppleTV' in device_name:
                                    if ', ' in device_name:
                                        device_name = device_name.replace(
                                            ', ', ' ').split()
                                        for pair in device_name:
                                            if pair not in self.devices['Apple TV']:
                                                self.devices['Apple TV'].append(
                                                    pair)
                                        continue

                                    if device_name not in self.devices['Apple TV']:
                                        self.devices['Apple TV'].append(
                                            device_name)


def main() -> None:
    parser = ArgumentParser()

    parser.add_argument('--test', action='store_true')

    args = parser.parse_args()

    if args.test:
        w = Wiki()
        w.getAllDevices()
    else:
        sys.exit(parser.print_help(sys.stderr))


if __name__ == '__main__':
    main()
