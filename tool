#!/usr/bin/env python3

import asyncio
import sys

from aiohttp import ClientSession


class Wiki:
    def __init__(self, session) -> None:
        self.session = session

    async def readFromURL(self, url):
        async with self.session.get(url) as r:
            if r.status == 200:
                return await r.text()
            else:
                raise ValueError(f'Got status code: {r.status}!')

    async def readModels(self):
        url = 'https://www.theiphonewiki.com/w/index.php?title=Models&action=raw'
        data = await self.readFromURL(url)
        data = data.splitlines()
        info = {}
        for i, line in enumerate(data):
            if '== [[' in line:
                if '|' in line:
                    name = line.split('|')[1].replace(']] ==', '')
                    info[name] = {}
                    info[name]['start'] = i
                else:
                    name = line.replace('== [[', '').replace(']] ==', '')
                    info[name] = {}
                    info[name]['start'] = i

            if line == '|}':
                info[name]['end'] = i
                info[name]['data'] = data[info[name]
                                          ['start']:info[name]['end']+1]


async def main(args: tuple) -> None:
    async with ClientSession() as session:
        w = Wiki(session)
        await w.readModels()

if __name__ == '__main__':
    asyncio.run(main(tuple(sys.argv)))
