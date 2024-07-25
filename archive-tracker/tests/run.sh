#!/bin/bash -e

script="$(realpath ../archive-tracker.sh)"
test="$(realpath no-change)"

pushd "$test"
ARCHIVE_DIR="" TRACKER_DIR="" "$script"
popd
