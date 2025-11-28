package 'yum-utils'

execute 'apply-updates' do
  command 'dnf update -y'
end

service 'sshd' do
  action :restart
end
