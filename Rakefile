Dir.glob("./lib/task/*.rake"){|p|import p}

desc "wifi/wpa WIFI_PSK=? "
task :wpa => 'wifi:wpa'

desc "wifi/wep WIFI_PSK=?"
task :wep => 'wifi:wep'

desc "list aps"
task :list => 'wifi:list'

desc "shutterstock wlan via cmd line"
task :work2 do
  opts = 'key_mgmt=WPA-EAP pairwise=CCMP group=CCMP eap=PEAP'
  sh "rake wifi:wpa[Shutterstock,#{ENV['WIFI_PSK']},wlan0,'#{opts}']"
end

desc "work (openvpn) via gui"
task :work do
  sh "sudo wpa_gui -i wlan0"
  sh "sudo dhclient wlan0"
  sh "rake vpn"
  puts "add \"nameserver 10.100.1.5\" to resolv.conf".red
end

LOGNAME = ENV['LOGNAME']
desc "vpn to work"
task :vpn do
  Dir.chdir "/home/#{LOGNAME}/.openvpn" do
    sh "sudo openvpn ./config.ovpn"
  end
end

desc "home via gui"
task :home do
  sh "sudo wpa_gui -i wlan0"
  sh "sudo dhclient wlan0"
end

desc "restart network manager"
task :restart => 'wifi:restart'

