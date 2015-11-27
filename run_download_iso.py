#!/usr/bin/python


import jenkins
import sys

server = jenkins.Jenkins('http://jenkins-tpi.bud.mirantis.net:8080', username='rkhozinov', password='7d0afaf10fe8866eed8c2f43cac83fbf')
version = server.get_version()
server.build_job('download_iso',{'RELEASE':'8.0'})



