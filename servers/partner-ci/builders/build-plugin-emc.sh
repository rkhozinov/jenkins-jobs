#!/bin/bash
set -e

git log  --pretty=oneline | head

find $PUPPETLINT_PATH -name '*.erb' -print0 | xargs -0 -P1 -L1 -I '%' erb -P -x -T '-' % | ruby -c
find $PUPPETLINT_PATH -name '*.pp' -print0  | xargs -0 -P1 -L1 puppet parser validate --verbose
find $PUPPETLINT_PATH -name '*.pp' -print0  | xargs -0 -P1 -L1 -r puppet-lint \
         --fail-on-warnings \
         --with-context \
         --with-filename \
         --no-80chars-check \
         --no-variable_scope-check \
         --no-nested_classes_or_defines-check \
         --no-autoloader_layout-check \
         --no-class_inherits_from_params_class-check \
         --no-documentation-check \
         --no-arrow_alignment-check

fpb --check  ./

[[ "${DEBUG}" == "true" ]] && fpb --debug --build ./ | fpb --build ./

pkg_name=$(ls -t *.rpm | head -n1)
mv $pkg_name $(echo $pkg_name | head -n 1 | sed s/.noarch/-$BUILD_NUMBER.noarch/)
