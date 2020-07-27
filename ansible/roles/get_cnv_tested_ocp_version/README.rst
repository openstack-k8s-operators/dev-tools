get_cnv_tested_ocp_version

This role can be used to retrieve OCP version that is tested
by the downstream CNV CI system.

The way it works is very simple and expects remote file that
contains one string which describes OCP version.

**Role Variables**

.. rolevar:: ocp_fallback_release_version
   :default: '4.4.0-rc.7'

   OCP version to be used if CNV CI version can't be calculated.

.. rolevar:: ocp_cnv_tested_version_url
   :default: 'http://staging-jenkins2-qe-playground.usersys.redhat.com/job/OCP4.4-retrieve-verified-version-poc/lastSuccessfulBuild/artifact/oc_server_version.html'

   URL containing latest verified by the CNV CI version of OCP.

.. rolevar:: ocp_registry_url
   :default: 'registry.svc.ci.openshift.org/ocp/release'

   URL for the OCP to be used
