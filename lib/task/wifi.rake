namespace :wifi do
  require 'smart_colored/extend'

  INTERFACE = ENV['WIFI_IFACE']  || 'wlan1'
  SSID = ENV['WIFI_SSID'] || 'topos'
  PSK = ENV['WIFI_PSK']

  desc 'conect to wifi, wpa auth'
  task :wpa, [:ssid,:psk,:iface] do |t,arg|
    arg.with_defaults(ssid: SSID, psk: PSK, iface: INTERFACE)
    task('wifi:stop').invoke(arg.iface)
    task('wifi:conf').invoke(arg.ssid,arg.psk)
    sh "sudo ifconfig #{arg.iface} down"
    sh "sudo iwconfig #{arg.iface} mode Managed"
    sh "sudo ifconfig #{arg.iface} up"
    sh "sudo wpa_supplicant -B -i#{arg.iface} -c/var/tmp/wpa_supplicant.conf -Dwext"
    sh "sudo dhclient #{arg.iface}"
  end

  desc 'conect to wifi, wep'
  task :wep, [:ssid,:psk,:iface] do |t,arg|
    arg.with_defaults(ssid: SSID, psk: PSK, iface: INTERFACE)
    sh "sudo ifconfig #{arg.iface} down"
    sh "sudo iwconfig #{arg.iface} mode Managed"
    sh "sudo ifconfig #{arg.iface} up"
    sh "sudo iwconfig #{arg.iface} essid '#{arg.ssid}'"
    unless arg.psk.nil? 
      sh "sudo iwconfig #{arg.iface} key s:#{arg.psk}"
    end
    sh "sudo dhclient #{arg.iface}"
  end


  desc "list access points"
  task :list, [:iface] do |t,arg|
    arg.with_defaults(iface:'wlan1')
    sh "sudo ifconfig #{arg.iface} up"
    cs = cells(`sudo iwlist #{arg.iface} scanning|egrep 'Cell |Encryption|Quality|Last beacon|ESSID'`)
    aps = []
    cs.each do |ps|
      h = {}
      ps.each do |p|
        h[p.first] = p.last
      end
      aps << h
    end
    aps.select{|e|!e['ESSID'].nil?}.sort_by{|h|h['ESSID']}.each.with_index do |ap,i|
      a = "#{ap['ESSID']}    #{ap['Quality']}"
      if ap['Encryption key'] == 'on'
        puts a.red
      else
        puts a.green
      end
    end
  end

  task :conf, [:ssid,:psk] do |t,arg|
    psk = `wpa_passphrase "#{arg.ssid}" "#{arg.psk}"|grep -v '#psk='|grep psk`.strip
    c = [] 
    c << 'network={'
    c << "  scan_ssid=1"
    c << "  ssid=\"#{arg.ssid}\""
    c << "  #{psk}" unless psk.nil? || psk == ''
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

  desc "gui"
  task :gui, [:iface] do |t,arg|
    arg.with_defaults(iface: 'wlan1')
    sh "sudo wpa_gui -i #{arg.iface}"
  end

  def cells(block)
    cs = []
    block.split('Cell').each do |c|
      l = c.split(/Cell\s+[0-9]+/).map{|l|l.strip}.first
      cs << l.split("\n").map{|e|e.strip}.map do |e|
        if e.include? 'Address:'
          e.split('-').last.split(':',2)
        else
          e.split(/:|=/)
        end.map{|x|x.strip}
      end
    end
    cs
  end
end
