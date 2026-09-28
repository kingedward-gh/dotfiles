#!/usr/bin/env python2

from subprocess import Popen, PIPE
import json
import re
import os
import sys


filter = False

if len(sys.argv) > 1:
    filter = sys.argv[1]

data = {}
data['rerun'] = 5 # rerun tysk every x seconds
data['items'] = []
json_data = json.dumps(data)

i = 0
p = Popen(["ps", "-arwwwxo", "pid nice %cpu %mem state comm"], stdout=PIPE, bufsize=1)

with p.stdout:
	for line in iter(p.stdout.readline, b''):

		# remove first line of ps (column headers)
		if i == 0:
			i = i + 1
			continue

		# check for process name filter
		if filter and not re.search(filter, line, re.I):
			continue


		[ pid, nice, cpu, mem, state, command ] = line.split(None, 5)

		item = {
			'type': 'default',
			'title': os.path.basename(command),
			'subtitle': "CPU: {}% MEM {}%".format(cpu, mem),
			'arg': pid,
			'text': {
				'largetype': command
			}
		}

		# check for app title
		app = re.search(r'\/([a-z0-9\s]+)\.app\/', command, re.I)
		if app:
			item['title'] = app.group(1)

			icon = re.search(r'^(\/.*\.app)\/', command, re.I)
			if icon:
				item['icon'] = {}
				item['icon']['type'] = "fileicon"
				item['icon']['path'] = icon.group(1)

		data['items'].append(item)


p.wait() # wait for the subprocess to exit


print json.dumps(data)
