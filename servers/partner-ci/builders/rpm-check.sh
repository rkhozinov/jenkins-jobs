#!/bin/bash

rs1='preinstall program: /bin/sh'
rs2='postinstall program: /bin/sh'
rs3='preuninstall program: /bin/sh'

pname=$(grep '^name:' metadata.yaml)
pver=$(grep '^version:' metadata.yaml)
cname=$(echo "${pname}"|cut -d ' ' -f 2)
cver=$(echo "${pver}"|cut -d ' ' -f 2|cut -d '.' -f 1,2)
msg=$(rpm -qlp ./*.rpm |grep -v  /var/www/nailgun/plugins/"${cname}-${cver}")
[ -z "${msg}" ] && echo "msg is clear"

shs1=$(rpm -qp --scripts ./*.rpm|grep 'preinstall program:')
shs2=$(rpm -qp --scripts ./*.rpm|grep 'postinstall program:')
shs3=$(rpm -qp --scripts ./*.rpm|grep 'preuninstall program:')

echo -e "${shs1}\\n \
         ${shs2}\\n \
         ${shs3}\\n"

if [[ -n "${shs1}" && "${rs1}" != "${shs1}" ]]; then
  echo "Bad Preinstall Script"
  exit 1
fi
if [[ -n "${shs2}" && "${rs2}" != "${shs2}" ]]; then
  echo "Bad Postinstall Script"
  exit 1
fi

if [[ -n "${shs3}" && "${rs3}" != "${shs3}" ]]; then
  echo "Bad preuninstall Script"
  exit 1
fi
