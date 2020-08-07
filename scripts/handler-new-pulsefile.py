#! /usr/bin/env python
import json
import os
import re
import subprocess
import sys
from typing import Tuple


def parse_path(core: str) -> Tuple[str, str, str, int, int]:
    '''
    Parse path and filename to retrieve user, machine, version, shot and run.

    :param core: The path to file without extension i.e. /home/imas/public/imasdb/test/3/0/ids_10001
    :return: A 5-tuple with user, machine, version, shot and run.
    '''
    match = re.search(r'.+/(.+?)/public/imasdb/(.+?)/([^/]+).*', core)
    user, tokamak, version = match.group(1), match.group(2), match.group(3)
    number = os.path.basename(core).replace('ids_', '')
    shot = int(number[:-4].lstrip('0'))  # last 4 digits are for run
    run = os.path.basename(os.path.dirname(core)) + number[-4:]
    run = run.lstrip('0')
    run = int(run) if run else 0
    return user, tokamak, version, shot, run


if __name__ == '__main__':
    if len(sys.argv) == 2:
        core, extension = os.path.splitext(sys.argv[1])

        # process data only if the extension is .populate
        if extension == '.populate':
            user, tokamak, version, shot, run = parse_path(core)

            # try to parse contents of .populate file as JSON data
            with open(sys.argv[1]) as infile:
                content = infile.read()
                data = json.loads(content if content.strip() else '{}')

            # add additional experiment URI params read from .populate JSON here
            occurrence = f';occurrence={data["occurrence"]}' if 'occurrence' in data else ''

            command = ['java',
                       '-jar',
                       '/home/imas/opt/catalog_qt_2/client/catalog-ws-client/target/catalogAPI.jar',
                       '-addRequest',
                       '--user',
                       'imas-inotify-auto-updater',
                       '--url',
                       'http://localhost:8080',
                       '--experiment-uri',
                       f'mdsplus:/?user={user};machine={tokamak};version={version};shot={shot};run={run}{occurrence}']
            print('Executing command: {}'.format(' '.join(command)))
            subprocess.run(command)
