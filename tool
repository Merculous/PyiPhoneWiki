#!/usr/bin/env python3

import asyncio
import re
import sys

from aiohttp import ClientSession


class Wiki:
    def __init__(self, session) -> None:
        self.session = session
        self.supported = (
            'AirPods', 'AirTag', 'Apple TV',
            'Siri Remote', 'Apple Watch', 'HomePod',
            'iPad', 'Apple Pencil', 'Smart Keyboard',
            'iPad Air', 'iPad Pro', 'iPad mini',
            'iPhone', 'iPod touch', 'iMac', 
            'Mac mini', 'MacBook Air', 'MacBook Pro',
            'Mac Studio'
        )

    async def readFromURL(self, url):
        async with self.session.get(url) as r:
            if r.status == 200:
                return await r.text()
            else:
                raise ValueError(f'Got status code: {r.status}!')

    async def getSections(self):
        url = 'https://www.theiphonewiki.com/w/index.php?title=Models&action=raw'
        data = await self.readFromURL(url)
        data = data.splitlines()
        sections = []
        info = {}

        for supported in self.supported:
            for i, line in enumerate(data):
                if supported in line:
                    if '==' in line:
                        tmp2 = [i, line]
                        
                if line == '|}':
                    if len(tmp2) == 2:
                        tmp2.append(i)
                        if tmp2 not in sections:
                            sections.append(tmp2)

        for supported in self.supported:
            for section in sections:
                if supported in section[1]:
                    section_data = data[section[0]:section[2]+1]
                    info[supported] = {}
                    info[supported]['start'] = section[0]
                    info[supported]['end'] = section[2]
                    info[supported]['data'] = section_data

        return info



async def main(args: tuple) -> None:
    async with ClientSession() as session:
        w = Wiki(session)
        await w.getSections()

if __name__ == '__main__':
    asyncio.run(main(tuple(sys.argv)))
