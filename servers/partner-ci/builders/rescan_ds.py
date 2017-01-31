#!/usr/bin/env python

"""Copyright 2016 Mirantis, Inc.

Licensed under the Apache License, Version 2.0 (the "License"); you may
not use this file except in compliance with the License. You may obtain
copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
License for the specific language governing permissions and limitations
under the License.
"""

import atexit
import logging as log
import ssl
import sys
from os import environ
from os import path

sys.path.append(path.join(sys.path[0], "{0}/bin".format(environ.get('VIRTUAL_ENV'))))

import requests
from pyVim import connect
from pyVmomi import vim
from pyVmomi import vmodl

requests.packages.urllib3.disable_warnings()
log.getLogger("requests").setLevel(log.WARNING)
log.basicConfig(format='%(message)s', level=log.INFO)


class NotFoundException(Exception):
    """Raise when some object cannot be found."""

    pass


class Victl(object):
    """VMware base actions."""

    _service_instance = None
    content = None
    _datacenter = None
    _hosts = []
    _clusters = []

    def __init__(self, host, dc_name, user, password, port):
        """Create ssl context."""

        try:
            # workaround https://github.com/vmware/pyvmomi/issues/235
            context = ssl.SSLContext(ssl.PROTOCOL_TLSv1)
            context.verify_mode = ssl.CERT_NONE
            self._service_instance = connect.SmartConnect(host=host, user=user, pwd=password,
                                                          port=int(port), sslContext=context)

            if not self._service_instance:
                raise Exception('Could not connect to the specified host using'
                                ' specified username and password')

            atexit.register(connect.Disconnect, self._service_instance)
            self.content = self._service_instance.RetrieveContent()

        except vmodl.MethodFault as e:
            raise Exception('Caught vmodl fault: ' + e.msg)


    @property
    def datacenter(self):
        if not self._datacenter:
            self._datacenter = self.content.rootFolder
        return self._datacenter

    @property
    def hosts(self):
        if not self._hosts:
            host_view = self.content.viewManager.CreateContainerView(self.datacenter,
                                                                     [vim.HostSystem],
                                                                     True)
            self._hosts = [host for host in host_view.view]
            host_view.Destroy()

        return self._hosts

    def rescan_datastores(self):
        """Rescan all datastores."""
        [host.configManager.storageSystem.RescanAllHba() for host in self.hosts]
        log.info('Rescan was successful')
        return 0

    def datastore_list(self):
        """Print list of datastores."""
        for host in self.hosts:
            log.info("  On esxi '{0}' datastores:".format(host.name))
            for ds in host.datastore:
                log.info("\t'{0}'".format(ds.name))


if __name__ == '__main__':

    host = environ.get('VCENTER_IP', '172.16.0.145')
    port = environ.get('VCENTER_PORT', '443')
    user = environ.get('VCENTER_USERNAME', 'openstack')
    password = environ.get('VCENTER_PASSWORD', 'vmware')
    dc_name = environ.get('VC_DATACENTER', 'Datacenter')
    datastore = environ.get('VC_DATASTORE', 'nfs')
    clusters = environ.get('VCENTER_CLUSTERS', 'Cluster1')

    victl = Victl(host=host, dc_name=dc_name, user=user,
                    password=password, port=port)

    victl.rescan_datastores()
    victl.datastore_list()
