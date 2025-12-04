#!/usr/bin/env python3
"""Hook that times out (for testing timeout handling)"""
import json
import sys
import time

input_data = json.load(sys.stdin)

# Sleep for 30 seconds - will timeout with default 10s timeout
time.sleep(30)

sys.exit(0)
