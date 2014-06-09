namespace :wep do
  desc 'conect to wifi over wep'
  task :start, [:ssid,:password,:iface] do |t,arg|
    arg.with_defaults(iface: 'wlan1')
    sh "sudo ifconfig #{arg.iface} down"
    sh "sudo iwconfig #{arg.iface} mode Managed"
    sh "sudo ifconfig #{arg.iface} up"
    sh "sudo iwconfig #{arg.iface} essid #{arg.ssid}"
    unless arg.password.nil? 
      sh "sudo iwconfig #{arg.iface} key s:#{arg.password}"
    end
    sh "sudo dhclient #{arg.iface}"
  end
end
