#!/bin/bash

set -euo pipefail

rm -rf output
bash solution/solve.sh
pytest -v tests/test_outputs.py
