import os

import testinfra.utils.ansible_runner

testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    os.environ['MOLECULE_INVENTORY_FILE']
).get_hosts('all')


def test_hosts_file(host):
    f = host.file('/etc/hosts')

    assert f.exists
    assert f.user == 'root'
    assert f.group == 'root'


def test_apache2_is_installed(host):
    apache2 = host.package("apache2")
    assert apache2.is_installed
    assert apache2.version.startswith("2.4.29")


def test_apache2_running_and_enabled(host):
    apache2 = host.service("apache2")
    assert apache2.is_running
    assert apache2.is_enabled
