#!/usr/bin/env sh
# GNU GENERAL PUBLIC LICENSE
# Version 3, 29 June 2007
#
# Copyright (C) 2023 rydnr https://github.com/pythoneda-shared-code-requests/shared
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#

echo "Running @ENTRYPOINT@"
export _PYTHONEDA_PYTHON="@PYTHON@/bin/python"
export PYTHONPATH="@PYTHONPATH@"
export PYTHONPATH="$($_PYTHONEDA_PYTHON @PYTHONEDA_SHARED_PYTHONEDA_DOMAIN@/dist/scripts/process_pythonpath.py sort)"
export _PYTHONEDA_DEPS="$(echo $PYTHONPATH | sed 's : \n g' | wc -l)"
export _PYTHONEDA_PYTHONEDA_DEPS="$(echo $PYTHONPATH | sed 's : \n g' | grep 'pythoneda' | wc -l)"
@PYTHONEDA_SHARED_PYTHONEDA_BANNER@/bin/banner.sh -o "@ORG@" -r "@REPO@" -t "@VERSION@" -s "@PESCIO_SPACE@" -a "@ARCH_ROLE@" -l "@HEXAGONAL_LAYER" -p "@PYTHON_VERSION@" -D "$_PYTHONEDA_DEPS" -d "$_PYTHONEDA_PYTHONEDA_DEPS" -n "@NIXPKGS_RELEASE@"
$_PYTHONEDA_PYTHON @ENTRYPOINT@
