import json, subprocess, pathlib
p = pathlib.Path.home() / '.claude/settings.json'
s = json.loads(p.read_text())
s['env']['GITHUB_PERSONAL_ACCESS_TOKEN'] = subprocess.check_output(['gh', 'auth', 'token']).decode().strip()
p.write_text(json.dumps(s, indent=2) + '\n')
print('updated')
