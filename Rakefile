Dir.glob("./lib/task/*.rake"){|p|import p}

desc "wifi/wpa WIFI_PSK=? "
task :wpa => 'wifi:wpa'

desc "wifi/wep WIFI_PSK=?"
task :wep => 'wifi:wep'

desc "list aps"
task :list => 'wifi:list'

desc "shutterstock wlan via cmd line"
task :work do
  opts = 'key_mgmt=WPA-EAP pairwise=CCMP group=CCMP eap=PEAP'
  sh "rake wifi:wpa[Shutterstock,#{ENV['WIFI_PSK']},wlan0,'#{opts}']"
end

LOGNAME = ENV['LOGNAME']
desc "vpn to work"
task :vpn do
  Dir.chdir "/home/#{LOGNAME}/.openvpn" do
    sh "sudo openvpn ./config.ovpn"
  end
end

desc "home via command line" 
task :home do
  raise "ENV WIFI_IFACE not set" if ENV['WIFI_IFACE'].nil?
  raise "ENV WIFI_PSK not set" if ENV['WIFI_PSK'].nil?
  sh "rake wifi:wpa[topos,'#{ENV['WIFI_PSK'].gsub(',','\,')}',#{ENV['WIFI_IFACE']},'key_mgmt=WPA-PSK']"
  sh "sudo dhclient #{ENV['WIFI_IFACE']}"
end

desc "restart network manager"
task :restart => 'wifi:restart'
