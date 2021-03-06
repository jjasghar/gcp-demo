#
# Cookbook:: build_cookbook
# Recipe:: provision
#
# Copyright:: 2017, The Authors, All Rights Reserved.

if node['delivery']['change']['stage'] == 'acceptance'
  bash "bootstrap a tk node and clean up other node" do
    cwd delivery_workspace_repo
    code <<-EOH
      STATUS=0
      chef exec kitchen verify || STATUS=1
      chef exec knife google server create acceptance \
        --gce-image ubuntu-1604-lts --gce-machine-type #{node['gce_build_cookbook']['machine_type']} \
        --gce-public-ip ephemeral --ssh-user #{node['gce_build_cookbook']['ssh_username']} \
        --gce-project #{node['gce_build_cookbook']['project']} --gce-zone #{node['gce_build_cookbook']['zone']} \
        --identity-file #{node['gce_build_cookbook']['identity_file']} \ -r 'recipe[gcp_demo::default]' || STATUS=1
      exit $STATUS
    EOH
  end
end
if node['delivery']['change']['stage'] == 'union'
  bash "One last tk run to verify everything" do
    cwd delivery_workspace_repo
    code <<-EOH
      STATUS=0
      chef exec knife google server delete acceptance -y -P --gce-project #{node['gce_build_cookbook']['project']} --gce-zone #{node['gce_build_cookbook']['zone']}
      chef exec knife google server create union \
        --gce-image ubuntu-1604-lts --gce-machine-type #{node['gce_build_cookbook']['machine_type']} \
        --gce-public-ip ephemeral --ssh-user #{node['gce_build_cookbook']['ssh_username']} \
        --gce-project #{node['gce_build_cookbook']['project']} --gce-zone #{node['gce_build_cookbook']['zone']} \
        --identity-file #{node['gce_build_cookbook']['identity_file']} \ -r 'recipe[gcp_demo::default]' || STATUS=1
      exit $STATUS
    EOH
  end
end
if node['delivery']['change']['stage'] == 'rehearsal'
  bash "Delete the acceptance node" do
    cwd delivery_workspace_repo
    code <<-EOH
      STATUS=0
      chef exec knife google server delete union -y -P --gce-project #{node['gce_build_cookbook']['project']} --gce-zone #{node['gce_build_cookbook']['zone']}
      chef exec knife google server create rehearsal \
        --gce-image ubuntu-1604-lts --gce-machine-type #{node['gce_build_cookbook']['machine_type']} \
        --gce-public-ip ephemeral --ssh-user #{node['gce_build_cookbook']['ssh_username']} \
        --gce-project #{node['gce_build_cookbook']['project']} --gce-zone #{node['gce_build_cookbook']['zone']} \
        --identity-file #{node['gce_build_cookbook']['identity_file']} \ -r 'recipe[gcp_demo::default]' || STATUS=1
      exit $STATUS
    EOH
  end
end
