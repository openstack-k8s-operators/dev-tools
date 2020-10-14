default: \
  ocp_install \
  olm \
  #osp_operators_install \
  #osp_tests_run

all: default

hosts:
	echo -e "localhost ansible_connection=local\n\n[convergence_base]\nlocalhost" > $@

local-defaults.yaml:
	echo -e "vars:" > $@

local-deps:
	ansible-galaxy install -r requirements.yml

ocp_install:
	$(MAKE) host_prep
	$(MAKE) dev_scripts
	$(MAKE) post_install

host_prep: hosts local-deps local-defaults.yaml
	ANSIBLE_FORCE_COLOR=true ansible-playbook -i hosts -e @local-defaults.yaml \
	01_prepare_host.yaml \
	03_ocp_dev_scripts_prep.yaml

dev_scripts: hosts local-defaults.yaml
	ANSIBLE_FORCE_COLOR=true ansible-playbook -i hosts -e @local-defaults.yaml \
	03_ocp_dev_scripts.yaml

post_install: hosts local-defaults.yaml
	ANSIBLE_FORCE_COLOR=true ansible-playbook \
	-i hosts -e @local-defaults.yaml \
	04_local_oc_client.yaml \
	05_default_storageclass.yaml \
	ocp_image_registry.yaml \
	11_setup_extra_nics_on_vms.yaml \
	perf_sriov.yaml

osp_operators_install: compute_node
compute_node: hosts local-defaults.yaml
	ANSIBLE_FORCE_COLOR=true ansible-playbook \
	-i hosts -e @local-defaults.yaml \
        09_create_common-config.yaml \
	12_setup_worker_osp_machineset.yaml

ocp_ovn_controller: hosts local-defaults.yaml
	ANSIBLE_FORCE_COLOR=true ansible-playbook \
	-i hosts -e @local-defaults.yaml \
	13_switch_ocp_ovn-controller.yaml


compute_common_config: hosts local-defaults.yaml
	ANSIBLE_FORCE_COLOR=true ansible-playbook \
	-i hosts -e @local-defaults.yaml \
    09_create_common-config.yaml

osp_content: hosts local-defaults.yaml
	ANSIBLE_FORCE_COLOR=true ansible-playbook \
	-i hosts -e @local-defaults.yaml \
	13_switch_ocp_ovn-controller.yaml \
        osp_content.yaml

osp_tests_run: hosts local-defaults.yaml
	ANSIBLE_FORCE_COLOR=true ansible-playbook \
	-i hosts -e @local-defaults.yaml \
  20_tempest_ocp.yaml \

ctlplane-operator: hosts local-defaults.yaml
	# NOTE: requires 'make olm'
	ANSIBLE_FORCE_COLOR=true ansible-playbook \
	-i hosts -e @local-defaults.yaml \
	install_namespace.yaml \
	install_ctlplane.yaml \

ctlplane-yamls: hosts local-defaults.yaml
	# NOTE: requires 'make olm'
	ANSIBLE_FORCE_COLOR=true ansible-playbook \
	-i hosts -e @local-defaults.yaml \
	install_glance_service_init.yaml \
	install_placement_service_init.yaml \
	install_nova_service_init.yaml \
	install_ovn.yaml \
	install_neutron-api.yaml

podified-ctlplane: ctlplane
ctlplane: hosts local-defaults.yaml ctlplane-operator ctlplane-yamls

olm: hosts local-defaults.yaml
	ANSIBLE_FORCE_COLOR=true ansible-playbook \
	-v -i hosts -e @local-defaults.yaml \
	install_namespace.yaml \
	olm.yaml

ocs: hosts local-defaults.yaml
	ANSIBLE_FORCE_COLOR=true ansible-playbook \
	-v -i hosts -e @local-defaults.yaml \
	ocs.yaml

openstackclient: hosts local-defaults.yaml
	ANSIBLE_FORCE_COLOR=true ansible-playbook \
	-v -i hosts -e @local-defaults.yaml \
	install_openstackclient.yaml \

olm_cleanup: hosts local-defaults.yaml
	ANSIBLE_FORCE_COLOR=true ansible-playbook \
	-v -i hosts -e @local-defaults.yaml \
	olm_cleanup.yaml

nfs_cleanup: hosts
	ANSIBLE_FORCE_COLOR=true ansible -i hosts convergence_base \
	--become -m shell -a \
	"set -x; \
	 rm -f /etc/exports.d/host-nfs-storageclass.exports; \
	 exportfs -ra; \
	 umount -d /home/nfs/pv-*; \
	 rm -rf /home/nfs; \
	 temp=$$(mktemp); \
	 grep -v "^/home/nfs/data/pv-" /etc/fstab > \$$temp; \
	 cat \$$temp > /etc/fstab; \
	 rm \$$temp"

destroy_ocp: hosts
	ANSIBLE_FORCE_COLOR=true ansible -i hosts convergence_base \
	--become --become-user ocp \
	-m shell -a "cd /home/ocp/dev-scripts && make clean"
	$(MAKE) nfs_cleanup

demo: hosts
	ANSIBLE_FORCE_COLOR=true ansible-playbook \
	-i hosts -e @local-defaults.yaml \
	demo.yaml

osp_cleanup: hosts local-defaults.yaml
	ANSIBLE_FORCE_COLOR=true ansible-playbook \
	-v -i hosts -e @local-defaults.yaml \
	osp_cleanup.yaml

ocs_cleanup: hosts local-defaults.yaml
	ANSIBLE_FORCE_COLOR=true ansible-playbook \
	-v -i hosts -e @local-defaults.yaml \
	ocs_cleanup.yaml
