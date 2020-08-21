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

host_prep: hosts local-deps
	ANSIBLE_FORCE_COLOR=true ansible-playbook -i hosts \
	01_prepare_host.yaml \
	03_ocp_dev_scripts_prep.yaml

dev_scripts: hosts
	ANSIBLE_FORCE_COLOR=true ansible-playbook -i hosts \
	03_ocp_dev_scripts.yaml

post_install: hosts local-defaults.yaml
	ANSIBLE_FORCE_COLOR=true ansible-playbook \
	-i hosts -e @local-defaults.yaml \
	04_local_oc_client.yaml \
	05_default_storageclass.yaml \
	ocp_image_registry.yaml

osp_operators_install: hosts local-defaults.yaml
	ANSIBLE_FORCE_COLOR=true ansible-playbook \
	-i hosts -e @local-defaults.yaml \
	12_setup_worker_osp_machineset.yaml \

osp_tests_run: hosts local-defaults.yaml
	ANSIBLE_FORCE_COLOR=true ansible-playbook \
	-i hosts -e @local-defaults.yaml \
  20_tempest_ocp.yaml \

podified-ctlplane: hosts ctlplane
ctlplane: local-defaults.yaml
	# NOTE: requires 'make olm'
	ANSIBLE_FORCE_COLOR=true ansible-playbook \
	-i hosts -e @local-defaults.yaml \
	install_namespace.yaml \
	install_mariadb.yaml \
	install_rabbitmq.yaml \
	install_keystone.yaml \
	install_glance.yaml \
	install_placement.yaml \
	install_ovn.yaml \
	install_neutron-api.yaml \
	install_nova-api.yaml \
	install_nova-cell.yaml

olm: hosts local-defaults.yaml
	ANSIBLE_FORCE_COLOR=true ansible-playbook \
	-v -i hosts -e @local-defaults.yaml \
	install_namespace.yaml \
	olm.yaml

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

ocp_cleanup: hosts
	ANSIBLE_FORCE_COLOR=true ansible -i hosts convergence_base \
	--become --become-user ocp \
	-m shell -a "cd /home/ocp/dev-scripts && make clean"
	$(MAKE) nfs_cleanup
