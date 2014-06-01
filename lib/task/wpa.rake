namespace :wpa do
  desc "connect to wifi: (ssid,iface)=(topos,wlan1)"
  task :start, [:ssid,:psk,:iface] do |t,arg|
    arg.with_defaults(ssid: ENV['WPA_SSID'] || 'topos', psk: ENV['WPA_PSK'], iface: ENV['WPA_IFACE'] || 'wlan1')
    task('wpa:stop').invoke(arg.iface)
    task('wpa:conf').invoke(arg.ssid,arg.psk)
    sh "sudo ifconfig #{arg.iface} down"
    sh "sudo iwconfig #{arg.iface} mode Managed"
    sh "sudo ifconfig #{arg.iface} up"
    sh "sudo wpa_supplicant -B -i#{arg.iface} -c/var/tmp/wpa_supplicant.conf -Dwext"
    sh "sudo dhclient #{arg.iface}"
  end

  task :conf, [:ssid,:psk] do |t,arg|
    psk = `wpa_passphrase "#{arg.ssid}" "#{arg.psk}"|grep -v '#psk='|grep psk`.strip
    c = [] 
    c << 'network={'
    c << "        scan_ssid=1"
    c << "        ssid=\"#{arg.ssid}\""
    c << "        #{psk}"
    c << '}'
    conf = c.join("\n")
    File.open('/var/tmp/wpa_supplicant.conf','w'){|f|f.write conf}
  end

  desc "stop wpa_supplicant and dhclient"
  task :stop, [:iface] do |t,arg|
    arg.with_defaults(iface: 'wlan1')
    ['dhclient','wpa_supplicant'].each{|p|sh "sudo pkill -9 #{p} || exit 0"}
    sh "sudo ifconfig #{arg.iface} down"
  end

  desc "install wpa supplicant"
  task :install do
    sh "sudo aptitude update -y"
    sh "sudo aptitude install -y cnetworkmanager"
    #sh "sudo aptitude install -y wpasupplicant"
  end    
end
