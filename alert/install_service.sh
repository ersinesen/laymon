sudo cp cpu_monitor.sh /usr/local/bin/
sudo cp cpu_monitor.service /etc/systemd/system/
sudo cp cpu_monitor.timer /etc/systemd/system/

sudo chmod +x /usr/local/bin/cpu_monitor.sh
sudo chmod +x /etc/systemd/system/cpu_monitor.service
sudo chmod +x /etc/systemd/system/cpu_monitor.timer

systemctl enable cpu_monitor.timer
systemctl start cpu_monitor.timer

systemctl status cpu_monitor.service
