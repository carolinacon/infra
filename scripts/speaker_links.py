#!/usr/bin/env -S uv run --script

# /// script
# requires-python = ">=3.12"
# dependencies = []
# ///

"""
Example: scripts/speaker_links.py 6 'https://vdo.ninja/check.html' 'https://vdo.ninja/?room=<>'
"""

from uuid import uuid4
from argparse import ArgumentParser

def main() -> None:
  parser = ArgumentParser()
  parser.add_argument('count', help='How many unique links you need')
  parser.add_argument('perf_base_url', help='VDO.ninja speaker guest base url')
  parser.add_argument('guest_base_url', help='VDO.ninja performance base url')
  args = parser.parse_args()

  for i in range(int(args.count)):
    current_guid = str(uuid4())
    print(f"{args.perf_base_url}?id={current_guid}")
    print(f"{args.guest_base_url}&push={current_guid.replace('-','_')}")


if __name__ == "__main__":
    main()
