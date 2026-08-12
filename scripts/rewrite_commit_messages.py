import sys

raw = sys.stdin.read()
if not raw:
    sys.exit(0)

lines = raw.splitlines()
if lines:
    subject = lines[0].strip()
    if subject.endswith("."):
        subject = subject[:-1]
    if subject and subject[0].isupper():
        subject = subject[0].lower() + subject[1:]
    lines[0] = subject

sys.stdout.write("\n".join(lines))
if raw.endswith("\n"):
    sys.stdout.write("\n")
