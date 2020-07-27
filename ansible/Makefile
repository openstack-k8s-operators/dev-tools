# To set a specific release to install, add the argument:
#   -e ocp_release_image=quay.io/openshift-release-dev/ocp-release:4.5.3-x86_64
# TODO: parameterise the above

default: \
  ocp_install \
  olm \
  osp_controller_prepare \
  osp_controller_install  \
  osp_operators_install \
  osp_tests_run

all: default

local-deps:
	ansible-galaxy install -r requirements.yml

demo:
	ANSIBLE_FORCE_COLOR=true ansible-playbook \
	demo_playbook.yaml

ocp_install: local-deps
	ANSIBLE_FORCE_COLOR=true ansible-playbook \
	-i hosts \
	01_prepare_host.yaml \
	02_local-nfs-server.yaml \
	03_ocp_dev_scripts.yaml \
	ocp_image_registry.yaml \

osp_controller_prepare:
	ANSIBLE_FORCE_COLOR=true ansible-playbook \
	-i hosts \
	03_ocp_cnv.yaml \
	04_osp-controller-vm-storage.yaml \
	05_osp-controller-vm-network.yaml \
	06_osp-create-controller-vms.yaml \

osp_controller_install:
	ANSIBLE_FORCE_COLOR=true ansible-playbook \
	-i hosts \
	07_osp_tripleo_deploy.yaml \
	09_create_common-config.yaml \

osp_operators_install:
	ANSIBLE_FORCE_COLOR=true ansible-playbook \
	-i hosts \
	12_setup_worker_osp_machineset.yaml \

osp_tests_run:
	ANSIBLE_FORCE_COLOR=true ansible-playbook \
	-i hosts \
  20_tempest_ocp.yaml \

podified-ctlplane:
	# NOTE: requires 'make olm'
	ANSIBLE_FORCE_COLOR=true ansible-playbook \
	-i hosts \
	install_mariadb.yaml \
	install_rabbitmq.yaml \
	install_keystone.yaml \
	install_heat_operator.yaml

olm:
	ANSIBLE_FORCE_COLOR=true ansible-playbook \
	-v -i hosts \
	olm.yaml

make olm_cleanup:
	ANSIBLE_FORCE_COLOR=true ansible-playbook \
	-v -i hosts \
	olm_cleanup.yaml

ocp_controller_cleanup:
	for i in `seq 0 2`; do su - ocp -c "cd; \
          export KUBECONFIG=dev-scripts/ocp/ostest/auth/kubeconfig; \
          oc delete -f cnv/controller-$$i.yaml; \
          oc delete -f cnv/controller-$$i-sc.yaml; \
          oc delete -f cnv/controller-$$i-pvc.yaml; \
          oc delete -f cnv/controller-$$i-pv.yaml"; \
        done

# XXX: WARNING!!! WARNING!!! DANGER WILL ROBINSON!!!
# YOU PROBABLY SHOULD NOT EXECUTE ANY OF THE FOLLOWING!
#
# Unlike the ansible playbooks, the following all assume you're executing this
# directly on the host.

clean: ocp_cleanup ctlplane_cleanup host_cleanup

host_cleanup:
	-echo | sudo tee /etc/exports

ocp_cleanup:
	-sudo su - ocp -c "cd dev-scripts && make clean"

ctlplane_cleanup:
	-sudo virsh net-destroy ctlplane
	-sudo virsh net-undefine ctlplane
