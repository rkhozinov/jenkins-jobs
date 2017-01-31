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

import argparse
import atexit
import logging as log
import ssl
import sys

from os import environ

import paramiko

from pyVim import connect

from pyVmomi import vim
from pyVmomi import vmodl

import requests

requests.packages.urllib3.disable_warnings()
log.getLogger("requests").setLevel(log.WARNING)
log.basicConfig(format='%(message)s', level=log.INFO)  # %(levelname)s:


class NotFoundException(Exception):
    """Raise when some object cannot be found."""

    pass


class Victl(object):
    """VMware base actions."""

    _service_instance = None
    content = None

    def __init__(self, host, user, password, port):
        """Create ssl context."""
        try:
            # workaround https://github.com/vmware/pyvmomi/issues/235
            context = ssl.SSLContext(ssl.PROTOCOL_TLSv1)
            context.verify_mode = ssl.CERT_NONE
            self._service_instance = connect.SmartConnect(host=host,
                                                          user=user,
                                                          pwd=password,
                                                          port=int(port),
                                                          sslContext=context)

            if not self._service_instance:
                raise Exception('Could not connect to the specified host using'
                                ' specified username and password')

            atexit.register(connect.Disconnect, self._service_instance)

            self.content = self._service_instance.RetrieveContent()

        except vmodl.MethodFault as e:
            raise Exception('Caught vmodl fault: ' + e.msg)

    def get_dc_object(self, datacenter):
        """Return datacenter object with specified name."""
        for dc in self.content.rootFolder.childEntity:
            if dc.name == datacenter:
                return dc

        raise NotFoundException("Can not find dc "
                                "'{0}'".format(datacenter))

    def get_cluster_hosts(self, dc, cluster):
        """Return list of hosts names in specified cluster."""
        host_folder = dc.hostFolder
        for _cluster in host_folder.childEntity:
            if _cluster.name == cluster:
                return [host.name for host in _cluster.host]

        raise Exception("Cluster '{0}' is empty".format(cluster))

    def get_cluster_hosts_objects(self, dc, cluster):
        """Return list of hosts objects in specified cluster."""
        host_folder = dc.hostFolder
        for _cluster in host_folder.childEntity:
            if _cluster.name == cluster:
                return _cluster.host

    def get_hosts(self, dc):
        """Return list of all hosts objects"""
        host_folder = dc.hostFolder
        hosts = []
        for _cluster in host_folder.childEntity:
            hosts += _cluster.host
        return hosts

    def get_vds_object(self, dc, vds):
        """Return dvSwitch object with specified name."""
        network_folder = dc.networkFolder
        for net in network_folder.childEntity:
            if isinstance(net, vim.DistributedVirtualSwitch):
                if net.name == vds:
                    return net

        raise NotFoundException("dvSwitch '{0}' not found".format(vds))

    def get_vds_hosts(self, datacenter, vdswitch):
        """Return list of hosts names in specified dvSwitch."""
        dc = self.get_dc_object(datacenter)
        vds = inst.get_vds_object(dc, vdswitch)
        return [host.config.host.name for host in vds.config.host]

    def get_nics_for_hosts_in_vds(self, hosts, vds):
        """Return list of nics for specified hosts in dvSwitch."""
        nics = []
        for host in vds.config.host:
            if host.config.host.name in hosts:
                nics.append([nic.pnicDevice for nic
                             in host.config.backing.pnicSpec])

        return nics

    def get_clusters(self, datacenter):
        """Return list of clusters names in specified datacenter."""
        dc = self.get_dc_object(datacenter)
        host_folder = dc.hostFolder
        return [cluster.name for cluster in host_folder.childEntity]

    def _exec_command(self, host, user, password, cmd):
        """Execute command remotely and return output."""
        client = paramiko.SSHClient()
        client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        try:
            client.connect(host, username=user, password=password, timeout=3)
            stdin, stdout, stderr = client.exec_command(cmd)
            out = stdout.read()
        except TypeError:
            raise Exception('There are no valid connections')
        finally:
            if client:
                client.close()
        return out

    def check_netcpad(self, host, user, password, print_error=False):
        """Check up whether connection with nsxv controller is established."""
        cmd = r"esxcli network ip connection list | grep tcp | grep 1234 | " \
              r"grep ESTABLISHED"
        out = self._exec_command(host, user, password, cmd)
        if not out:
            if print_error:
                raise Exception("Host '{0}' not connected to nsxv "
                                "controller".format(host))
            return False
        return True

    def restart_netcpad(self, host, user, password):
        """Restart netcpad."""
        log.info("Host '{0}', try restart netcpad".format(host))

        cmd = r"/etc/init.d/netcpad restart"
        self._exec_command(host, user, password, cmd)

    def check_portgroup_configured(self, datacenter, cluster, portgroup):
        """Check up whether portgroup is configured."""
        err = ''
        dc = self.get_dc_object(datacenter)
        hosts = self.get_cluster_hosts_objects(dc, cluster)
        for esxi in hosts:
            if portgroup not in [pg.name for pg in esxi.network]:
                err += "On esxi '{0}' portgroup '{1}' "\
                       "not found".format(esxi.name, portgroup)
        if err:
            raise NotFoundException(err)
        return True

    def check_storage_configured(self, datacenter, cluster, datastore):
        """Check up whether datastore is configured on cluster."""
        dc = self.get_dc_object(datacenter)
        hosts = self.get_cluster_hosts_objects(dc, cluster)

        err = {}

        for esxi in hosts:
            for ds in esxi.datastore:
                if ds.name == datastore:
                    break
            else:
                log.error('ERROR: On esxi "{0}" datastore "{1}" is not '
                          'found'.format(esxi.name, datastore))
                err[0] = 'Some datastores not found'
                continue

            for attached_host in ds.host:
                if attached_host.key == esxi:
                    break

            if attached_host.mountInfo.mounted:
                log.info('On esxi "{0}" datastore "{1}" is mounted'
                         ''.format(ds.name, esxi.name))
            else:
                log.error('ERROR: On esxi "{0}" datastore "{1}" is NOT '
                          'mounted'.format(ds.name, esxi.name))
                err[1] = 'Some datastores not mounted'

            if attached_host.mountInfo.accessible:
                log.info('On esxi "{0}" datastore "{1}" is accessible'
                         ''.format(ds.name, esxi.name))
            else:
                log.error('ERROR: On esxi "{0}" datastore "{1}" is NOT '
                          'accessible'.format(ds.name, esxi.name))
                err[2] = 'Some datastores not accessible'

        if err:
            raise NotFoundException('. '.join(err.values()))

        return True

    def write_test_datastore(self, datacenter, datastore, host):
        """Put the file with test data to specified datastore."""
        dc = self.get_dc_object(datacenter)
        if datastore not in [ds.name for ds in dc.datastore]:
            raise NotFoundException("Datastore '{0}' not found on '{1}' "
                                    "datacenter".format(datastore, datacenter))

        # Build the url to put the file - https://hostname:port/resource?params
        resource = '/folder/test_upload'
        params = {'dsName': datastore, 'dcPath': datacenter}
        http_url = 'https://{0}:443{1}'.format(host, resource)

        # Get the cookie built from the current session
        client_cookie = self._service_instance._stub.cookie
        # Break apart the cookie into it's component parts - This is more than
        # is needed, but a good example of how to break apart the cookie
        # anyways. The verbosity makes it clear what is happening.
        cookie_name = client_cookie.split('=', 1)[0]
        _path_etc = client_cookie.split('=', 1)[1]
        cookie_value = _path_etc.split(';', 1)[0]
        cookie_path = _path_etc.split(';', 1)[1].split(';', 1)[0].lstrip()
        cookie_text = " {0}; ${1}".format(cookie_value, cookie_path)
        # Make a cookie
        cookie = dict()
        cookie[cookie_name] = cookie_text

        # Get the request headers set up
        headers = {'Content-Type': 'application/octet-stream'}

        # Get the file to upload ready, extra protection by using with against
        # leaving open threads
        # Connect and upload the file
        request = requests.put(http_url,
                               params=params,
                               data='Test upload file',
                               headers=headers,
                               cookies=cookie,
                               verify=False)
        if not request.ok:
            raise Exception("Can not write test file to datastore "
                            "'{0}'".format(datastore))

        return True


def cluster_list(args, inst):
    """Print list of clusters."""
    clusters = inst.get_clusters(args.datacenter)
    for cluster in clusters:
        log.info(cluster)

    return 0


def check_dvs_attached(args, inst):
    """Return 0 if dvs is attached to hosts."""
    dc = inst.get_dc_object(args.datacenter)
    vds = inst.get_vds_object(dc, args.vdswitch)
    hosts_in_cluster = inst.get_cluster_hosts(dc, args.cluster)
    hosts_in_vds = inst.get_vds_hosts(args.datacenter, args.vdswitch)

    # Check up whether all cluster hosts are in dvSwitch
    host_not_in_vds = set(hosts_in_cluster) - set(hosts_in_vds)
    if host_not_in_vds:
        err = "In cluster '{0}' on dvSwitch '{1}' not found " \
              "hosts:".format(args.cluster, args.vdswitch)
        for host in host_not_in_vds:
            err += "\n  {0}".format(host)
        raise NotFoundException(err)

    # Check up whether all cluster hosts have vmnic attached
    nics = inst.get_nics_for_hosts_in_vds(hosts_in_cluster, vds)
    for hostname, host_nics in zip(hosts_in_cluster, nics):
        if args.vmnic not in host_nics:
            raise Exception("Host '{0}' has not attached nic '{1}' to "
                            "dvSwitch '{2}'".format(hostname,
                                                      args.vmnic,
                                                      vds.name))
        extra_nic = set(host_nics) - {args.vmnic}
        if extra_nic:
            log.info("Host '{0}' has extra nic '{1}' attached to "
                     "dvSwitch '{2}'".format(hostname,
                                               ','.join(extra_nic),
                                               vds.name))

    return 0


def check_esxi(args, inst):
    """Return 0 if esxi is connected to controller."""
    dc = inst.get_dc_object(args.datacenter)
    hosts_in_cluster = inst.get_cluster_hosts(dc, args.cluster)

    # Check up whether esxi is connected to controller
    for host in hosts_in_cluster:
        if not inst.check_netcpad(host, args.user, args.password):
            inst.restart_netcpad(host, args.user, args.password)

            if inst.check_netcpad(host, args.user, args.password, True):
                log.info('Host {0} reconnected to nsxv '
                         'controller'.format(host))
            else:
                log.info('Host {0} NOT reconnected to nsxv '
                         'controller'.format(host))

    return 0


def check_portgroup(args, inst):
    """Return 0 if portgroup is configured on cluster."""
    if inst.check_portgroup_configured(args.datacenter, args.cluster,
                                       args.portgroup):
        return 0


def check_datastore(args, inst):
    """Return 0 if datastore is configured on cluster."""
    inst.write_test_datastore(args.datacenter, args.datastore, args.host)
    if inst.check_storage_configured(args.datacenter, args.cluster,
                                     args.datastore):
        return 0


def datastore_list(args, inst):
    """Print list of datastores."""
    dc = inst.get_dc_object(args.datacenter)
    hosts = inst.get_cluster_hosts_objects(dc, args.cluster)
    log.info("In cluster '{0}'".format(args.cluster))

    for esxi in hosts:
        log.info("  On esxi '{0}' datastores:".format(esxi.name))

        for ds in esxi.datastore:
            log.info("    '{0}'".format(ds.name))

    return 0


def rescan_datastores(args, inst):
    """Rescan all datastores."""
    dc = inst.get_dc_object(args.datacenter)
    ds = inst.get_hosts(dc)
    for _ds in ds:
        _ds.configManager.storageSystem.RescanAllHba()
    log.info('Rescan was successful')
    return 0


v_host = environ.get('VCENTER_IP', '172.16.0.145')
v_user = environ.get('VCENTER_USERNAME', 'openstack')
v_passw = environ.get('VCENTER_PASSWORD', 'vmware')
v_dcenter = environ.get('VC_DATACENTER', 'Datacenter')
v_datastore = environ.get('VC_DATASTORE', 'nfs')
v_clusters = environ.get('VCENTER_CLUSTERS', 'Cluster1')


class Params(object):
    host = v_host
    user = v_user
    password = v_passw
    port = '443'
    datacenter = v_dcenter
    clusters = v_clusters
    datastore = v_datastore
    suser = 'root'
    spassword = 'swordfish'
    cluster = None


if __name__ == '__main__':
    args = Params()
    inst = Victl(args.host, args.user, args.password, args.port)

    rescan_datastores(args, inst)

    for cluster in args.clusters.split(','):
        args.cluster = cluster
        datastore_list(args, inst)

