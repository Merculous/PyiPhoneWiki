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

    async def getSections(self):
        url = 'https://www.theiphonewiki.com/w/index.php?title=Models&action=raw'
        data = await self.readFromURL(url)
        data = data.splitlines()

        sections = []

        for i, line in enumerate(data):
            if line == '':
                sections.append(i)

        sections = iter(sections)
        new_sections = []

        while True:
            try:
                x = next(sections)
                xx = next(sections)
                section = data[x:xx+1]
                if section not in new_sections:
                    new_sections.append(section)
            except StopIteration:
                break

        del new_sections[:2]
        return new_sections

    async def readSections(self):
        sections = await self.getSections()
        oof = ''

async def main(args: tuple) -> None:
    async with ClientSession() as session:
        w = Wiki(session)
        await w.readSections()

if __name__ == '__main__':
    asyncio.run(main(tuple(sys.argv)))
