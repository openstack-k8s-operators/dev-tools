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

ocp_install: hosts local-deps local-defaults.yaml
	ANSIBLE_FORCE_COLOR=true ansible-playbook \
	-i hosts -e @local-defaults.yaml \
	01_prepare_host.yaml \
	03_ocp_dev_scripts.yaml \
	04_local_oc_client.yaml \
	05_default_storageclass.yaml \
	ocp_image_registry.yaml \

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
	install_ovn.yaml

olm: hosts local-defaults.yaml
	ANSIBLE_FORCE_COLOR=true ansible-playbook \
	-v -i hosts -e @local-defaults.yaml \
	install_namespace.yaml \
	olm.yaml

olm_cleanup: hosts local-defaults.yaml
	ANSIBLE_FORCE_COLOR=true ansible-playbook \
	-v -i hosts -e @local-defaults.yaml \
	olm_cleanup.yaml

# XXX: WARNING!!! WARNING!!! DANGER WILL ROBINSON!!!
# YOU PROBABLY SHOULD NOT EXECUTE ANY OF THE FOLLOWING!
#
# Unlike the ansible playbooks, the following all assume you're executing this
# directly on the host.

clean: ocp_cleanup host_cleanup

host_cleanup:
	-echo | sudo tee /etc/exports

ocp_cleanup:
	-sudo su - ocp -c "cd dev-scripts && make clean"
