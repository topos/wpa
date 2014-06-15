Dir.glob("./lib/task/*.rake"){|p|import p}

desc "wifi/wpa WIFI_PSK=? "
task :wpa => 'wifi:wpa'

desc "wifi/wep WIFI_PSK=?"
task :wep => 'wifi:wep'

desc "list aps"
task :list => 'wifi:list'
