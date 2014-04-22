namespace :wlan do
  desc "list access points"
  task :list, [:iface] do |t,arg|
    arg.with_defaults(iface:'wlan1')
    sh "sudo iwlist #{arg.iface} scanning|egrep 'Cell |Encryption|Quality|Last beacon|ESSID'"
  end
end
