# !/usr/bin/env python3

import re
import sys
from argparse import ArgumentParser

from mwclient import Site


class Wiki:
    def __init__(self, device=None) -> None:
        self.site = Site('theiphonewiki.com')

        self.device = device

    def parseTemplate(self, data: str):
        data = data.split('{| ')[1].split('|}')[0].splitlines()
        version_min = 3  # Min len for iOS version string (e.g. 1.0)
        version_max = 8  # Max len for iOS version string (e.g. 99.99.99)
        version_reg = re.compile(r'(\d+)\.')  # Pattern for xx.xx.xx

        firmwares = []

        for i in range(len(data)):
            if data[i] == '|-':
                # I'm skipping two values, so original is 7
                info = {
                    'version': str,
                    'buildid': str,
                    'keys': bool,
                    'url': str,
                    'sha1': str,
                    'size': int
                }

                if data[i+1].startswith('| '):
                    # Some pages have two actual iOS versions (Apple TV for example), use 2nd
                    tmp1 = data[i+1].replace('| ', '')
                    tmp2 = data[i+2].replace('| ', '')

                    test = 0

                    if len(tmp1) and len(tmp2) in range(version_min, version_max+1):
                        if version_reg.search(tmp1):
                            test += 1

                        if version_reg.search(tmp2):
                            test += 1

                        if test == 2:
                            info['version'] = tmp2
                            info['buildid'] = data[i+4].replace('| ', '')
                        else:
                            oof = ''

                        info['url'] = data[i+7].split()[1][1:]
                        tags = ('<code>', '</code>')
                        hash = data[i+8].split()[1]

                        if tags[0] in hash:
                            hash = hash.replace(tags[0], '')

                        if tags[1] in hash:
                            hash = hash.replace(tags[1], '')

                        info['sha1'] = hash
                        info['size'] = data[i+9].split()[1].replace(',', '')

                        if info not in firmwares:
                            firmwares.append(info)

    def getAllDevices(self) -> dict:
        """
        Grab all internal names from each 'list of <devices>' page
        """

        devices = {
            'Apple TV': [],
            'iPad': [],
            'iPhone': [],
            'iPod': []
        }

        category = self.site.categories['Devices']

        for page in category:
            name = page.name

            if name.startswith('List'):
                for device in devices:
                    if device in name:
                        data = page.text().splitlines()
                        internal_name = '* Internal Name: '

                        for match in data:
                            if internal_name in match:
                                tags = ('<code>', '</code>')

                                for tag in tags:

                                    if tag in match:
                                        match = match.replace(tag, '')

                                match = match.replace(internal_name, '')

                                if 'AppleTV' in match:
                                    dest = devices['Apple TV']
                                    if match.count('AppleTV') > 1:
                                        match = match.split(', ')

                                        for tv in match:
                                            if tv not in dest:
                                                dest.append(tv)
                                    else:
                                        if match not in dest:
                                            dest.append(match)
                                else:
                                    dest = devices[device]

                                    if match.count(device) > 1:
                                        match = match.split(', ')

                                        for thing in match:
                                            if thing not in dest:
                                                dest.append(thing)
                                    else:
                                        if match not in dest:
                                            dest.append(match)

        return devices

    def getFirmwaresForDevice(self):
        if self.device:
            devices = self.getAllDevices()

            if 'AppleTV' in self.device:
                if self.device not in devices['Apple TV']:
                    raise Exception(f'{self.device} not found!')
            else:
                for match in devices:
                    if match in self.device:
                        if self.device not in devices[match]:
                            raise Exception(f'{self.device} not found!')

            category = self.site.categories['Firmware']
            firmwares = {}

            for page in category:
                name = page.name

                if 'AppleTV' in self.device:
                    s1 = 'Firmware/Apple TV/'

                    if name.startswith(s1):
                        data = page.text()

                        if self.device in data:
                            self.parseTemplate(data)

        else:
            raise Exception('A device was not passed!')


def main() -> None:
    parser = ArgumentParser()

    parser.add_argument('-d', nargs=1, type=str, metavar='device')

    args = parser.parse_args()

    if args.d:
        w = Wiki(args.d[0])
        w.getFirmwaresForDevice()
    else:
        sys.exit(parser.print_help(sys.stderr))


if __name__ == '__main__':
    main()
