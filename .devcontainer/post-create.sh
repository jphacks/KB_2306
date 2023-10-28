#!/bin/bash

SCRIPT_DIR=$(dirname $(readlink -f "$0"))

# Install Flutter
fvm install

sudo mkdir -p ${SCRIPT_DIR}/../firebase/functions/node_modules
sudo chown -R $(whoami) ${SCRIPT_DIR}

# Install npm dependencies for Firebase Functions
npm --prefix "${SCRIPT_DIR}/../firebase/functions" install

# Install python dependencies
pip install -r  "${SCRIPT_DIR}/../huggingface/requirements.txt"
pip install gradio
