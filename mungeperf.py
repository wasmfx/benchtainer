#!/usr/bin/python3

import re

def dump(cmd, time, row):
    
    print(f"time,", end='')
    for k, v in row.items():
        print(f"{k},", end='')
    print("cmd")
    
    print(f"{time},", end='')
    for k, v in row.items():
        print(f"{v},", end='')
    print(f'"{cmd}"')
    print()
    
time = 0
row = {}
with open("results/log.log") as f:
    for line in f:
        gs = re.match("Running,(.*)", line)
        if gs:
            if row:
                dump(cmd, time, row)
            cmd = gs[1]
                
        gs = re.match("Time: *([0-9.]+)", line)
        if gs:
            row = {}
            time = gs[1]

        gs = re.match("^([0-9]+),,([a-z:-]+),.*", line)
        if gs:  
            val = gs[1]
            name = gs[2]
            row[name] = val

    dump(cmd, time, row)
