# openstack-k8s/ansible

#### Provisioning steps

##### Provision the host

RHEL 8.1 via beaker manually or use:

```
cat <<EOF > /tmp/beaker-rhel8.xml
<job retention_tag="scratch">
  <whiteboard>
Provision rhel8 x86_64 on +32G RAM / +6 Cores / +128G HD
  </whiteboard>
  <recipeSet priority="Normal">
<recipe kernel_options="" kernel_options_post="" ks_meta="" role="RECIPE_MEMBERS" whiteboard="">
  <autopick random="false"/>
  <watchdog panic="ignore"/>
  <packages/>
  <ks_appends/>
  <repos/>
  <distroRequires>
<and>
  <distro_family op="=" value="RedHatEnterpriseLinux8"/>
  <distro_name op="=" value="RHEL-8.1.0"/>
  <distro_arch op="=" value="x86_64"/>
</and>
  </distroRequires>
  <hostRequires>
<and>
  <system>
<memory op="&gt;" value="90000"/>
  </system>
  <cpu>
<cores op="&gt;" value="6"/>
  </cpu>
  <disk>
<size op="&gt;" value="137438953472"/>
  </disk>
  <arch op="=" value="x86_64"/>
  <system_type op="=" value="Machine"/>
  <key_value key="HVM" op="=" value="1"/>
</and>
  </hostRequires>
  <partitions/>
  <task name="/distribution/install" role="STANDALONE"/>
  <task name="/distribution/reservesys" role="STANDALONE">
<params>
  <param name="RESERVETIME" value="1296000"/>
</params>
  </task>
</recipe>
  </recipeSet>
</job>
EOF

bkr job-submit /tmp/beaker-rhel8.xml
```

**Note**
If this is the only owned host in beaker it gets scheduled there automatically.
Don't use this without modification if you have multiple hosts as it might pick
the wrong one!

##### Clone the repository to the beaker host

The ansible playbooks can be used as any user, but this user needs to be able to
get root priviledges to the host via passwordless sudo.

```
ssh root@<beaker node>
dnf install -y git
git clone git@github.com:openstack-k8s-operators/dev-tools.git
```

##### Install Ansible

```
rpm --rebuilddb # Not required, but worth doing on a fresh install
dnf install -y http://download-node-02.eng.bos.redhat.com/rcm-guest/puddles/OpenStack/rhos-release/rhos-release-latest.noarch.rpm
rhos-release 16
dnf install -y ansible
rhos-release -x
```

##### Modify the variable files

Modify `ansible/vars/default.yaml` to meet your req.

##### Install all steps using the Makefile

There is a Makefile which runs all the steps per default

```
dnf install -y make
cd dev-tools/ansible
make
```

**Note**
01_prepare_host.yaml will delete the home lvs and grow the root partition to max.
In case there is data stored on /home, make a backup!

##### When installation finished

* On the local system add the required entries to your local /etc/hosts. The previous used ansible playbook also outputs the information:

```
cat <<EOF >> /etc/hosts
192.168.111.4   console-openshift-console.apps.ostest.test.metalkube.org console openshift-authentication-openshift-authentication.apps.ostest.test.metalkube.org api.ostest.test.metalkube.org prometheus-k8s-openshift-monitoring.apps.ostest.test.metalkube.org alertmanager-main-openshift-monitoring.apps.ostest.test.metalkube.org kubevirt-web-ui.apps.ostest.test.metalkube.org oauth-openshift.apps.ostest.test.metalkube.org grafana-openshift-monitoring.apps.ostest.test.metalkube.org
EOF
```

**Note**
The cluster name is used in the hostname records, where `ostest` is the default in dev-scripts.
Update the above example to use the cluster name set in the vars file.

Run:

```
sshuttle -r <user>@<virthost> 192.168.111.0/24 192.168.25.0/24
```

Now you can access the OCP console using your local web browser: <https://console-openshift-console.apps.ostest.test.metalkube.org>

User: `kubeadmin`
Pwd: `/home/ocp/dev-scripts/ocp/<cluster name>/auth/kubeadmin-password`

You can also access the OCP console using your local web browser: <http://192.168.25.100>

User: `admin`
Pwd: The admin password can be found in the `/home/stack/cnvrc` file on the undercloud.

##### Access the OCP env from cli

```
su - ocp
export KUBECONFIG=/home/ocp/dev-scripts/ocp/ostest/auth/kubeconfig
oc get pods -n openstack
```

#### Cleanup full env:

```
cd openstack-k8s/ansible
make cleanup
```

#### Othere possible cleanup steps

##### Delete ocp env only

```
cd openstack-k8s/ansible
make ocp_cleanup
```

##### Delete OSP controllers
```
cd openstack-k8s/ansible
make ocp_controller_cleanup
```

#### Run install steps manually

##### Run host prepare steps and configure local nfs server

```
cd openstack-k8s/ansible
ansible-playbook 01_prepare_host.yaml
ansible-playbook 02_local-nfs-server.yaml
```

**Note**
01_prepare_host.yaml will delete the home lvs and grow the root partition to max.
In case there is data stored on /home, make a backup!

##### Deploy OCP using dev-scripts

```
ansible-playbook 03_ocp_dev_scripts.yaml
```

This step also installs CNV!

To access the OCP web console do:

* On the local system add the required entries to your local /etc/hosts. The previous used ansible playbook also outputs the information:

```
cat <<EOF >> /etc/hosts
192.168.111.4   console-openshift-console.apps.ostest.test.metalkube.org console openshift-authentication-openshift-authentication.apps.ostest.test.metalkube.org api.ostest.test.metalkube.org prometheus-k8s-openshift-monitoring.apps.ostest.test.metalkube.org alertmanager-main-openshift-monitoring.apps.ostest.test.metalkube.org kubevirt-web-ui.apps.ostest.test.metalkube.org oauth-openshift.apps.ostest.test.metalkube.org grafana-openshift-monitoring.apps.ostest.test.metalkube.org
EOF
```

**Note**
The cluster name is used in the hostname records, where `ostest` is the default in dev-scripts.
Update the above example to use the cluster name set in the vars file.

Run:

```
sshuttle -r <user>@<virthost> 192.168.111.0/24
```

Now you can access the OCP console using your local web browser: <https://console-openshift-console.apps.ostest.test.metalkube.org>

User: `kubeadmin`
Pwd: `/home/ocp/dev-scripts/ocp/<cluster name>/auth/kubeadmin-password`


##### Deploy openstack-k8s-operators via OLM (Operator Lifecycle Manager)

Operators are now deployed via OLM!

To install all required operators in the cluster run the following Makefile
target:

```
make olm
```

This target runs the olm.yaml Ansible playbook to automate building and
installing the required OLM components. This includes:

* Operator images are currently pre-built only get installed by OLM.
* Generating a CSV (Cluster Service Version) for all the operators in the
  cluster. The operator images used for the CSV deployment resources can be
  controlled via Ansible variables in vars/default.yaml
  (nova_operator_image, etc). The version of the CSV is controlled by the
  csv_version variable in vars/default.yaml.
  Individual CSV's are built for each operator and then merged to
  create a single CSV for an 'OpenStack Operator'.
* Creating a "bundle" image that includes all required resources and publishing   the bundle image to the local registry (CRDs for all operators, CSV, etc)
* Creating an index which references the bundle above (called openstack-index).
* The images for the bundle and index images are pushed to the local OpenShift
  registry.

It should be pointed out that we have automated the creation of the bundle
and index images above so that we can use any combination of operator images
in each of our development environments. This allows you to customize things
and develope however you wish while also using OLM to ensure our permissions
are correct. Typically an administrator would not execute the OLM related
image build steps above.

Once the above build steps are completed the installation via OLM is scripted
to automatically:
* Create a CatalogSource which uses the openstack-index image.
* Wait for OLM to deploy the packagemanifests from the new custom CatalogSource   within the 'openstack' namespace.
* Create a custom OperatorGroup and Subscription for the CSV version we want
  to install.
* This begins the installation of all Operators, Roles, CRDs, etc into the
  cluster.

If at any point you would like to uninstall things via OLM there is
a separate Makefile target to do that:


```
make olm\_cleanup
```

This will delete the delete the CSV, Subscription, Catalogsource, and OperatorGroup.

NOTE: After uninstalling operators if you wish to re-install you should bump
the csv_version Ansible variable before running 'make olm' again within your
development environment to ensure a fresh version of all images gets pulled.

##### Create required common-config configmap

The operators required some common data, like additional entries to the hosts file and passwords to access the OSP API.
This get added from the overcloud data to the common-config configmap.

```
ansible-playbook 09_create_common-config.yaml
```

##### Create and configure MachineSet for worker-osp nodes

```
ansible-playbook 12_setup_worker_osp_machineset.yaml
```

##### Tempest to run functional test

Create a tempest pod in OCP to run it. Tempest run is triggerd in an initContainer that we can wait
for the "normal" pod container which just runs a sleep to come up in ready state.

```
ansible-playbook 20_tempest_ocp.yaml
```

Tempest can be controlled via default.yaml var file to be:
* enabled/disabled (default enabled)
  tempest_enabled: true/false
* tempest timeout in seconds to wait for the pod to come up:
  tempest_timeout: 1200
* tests to run, either empty array, which then triggers smoke test
  or a specified whitelist
  tempest_whitelist: []
  tempest_whitelist:
  - aaa
  - bbb
