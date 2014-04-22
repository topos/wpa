namespace :wpa do
  desc "connect to wifi, interface=wlan1"
  task :start, [:ssid,:psk,:interface] => [:stop,:conf] do |t,arg|
    arg.with_defaults(interface: 'wlan1')
    sh "sudo ifconfig #{arg.interface} down"
    sh "sudo iwconfig #{arg.interface} mode Managed"
    sh "sudo ifconfig #{arg.interface} up"
    sh "sudo wpa_supplicant -B -i#{arg.interface} -c/var/tmp/wpa_supplicant.conf -Dwext"
    sh "sudo dhclient #{arg.interface}"
  end

  task :conf, [:ssid,:psk] do |t,arg|
    psk = `wpa_passphrase "#{arg.ssid}" "#{arg.psk}"|grep -v '#psk='|grep psk`.strip
    c = [] 
    c << 'network={'
    c << "        ssid=\"#{arg.ssid}\""
    c << "        #{psk}"
    c << "        scan_ssid=1"
    c << '}'
    conf = c.join("\n")
    File.open('/var/tmp/wpa_supplicant.conf','w'){|f|f.write conf}
  end

  desc "stop wpa_supplicant and dhclient"
  task :stop, [:interface] do |t,arg|
    arg.with_defaults(interface: 'wlan1')
    ['dhclient','wpa_supplicant'].each{|p|sh "sudo pkill -9 #{p} || exit 0"}
    sh "sudo ifconfig #{arg.interface} down"
  end

  desc "install wpa supplicant"
  task :install do
    sh "sudo aptitude update -y"
    sh "sudo aptitude install -y cnetworkmanager"
    #sh "sudo aptitude install -y wpasupplicant"
  end    
end
