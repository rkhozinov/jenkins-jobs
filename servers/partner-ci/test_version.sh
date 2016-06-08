#!/bin/bash

ISO_FILE="fuel-9.0-mos-364.iso"
#ISO_FILE="fuel-9.0-mos-370-2016-05-18_06-18-59.iso"
[[ "$ISO_FILE" == *mos* ]] && echo "${ISO_FILE}" | cut -d'-' -f4-4 | tr -d '.iso' || \
                              echo "${ISO_FILE}" | cut -d'-' -f3-3 | tr -d '.iso'
