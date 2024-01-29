##Socket Sender Program

This program directly connects to an FTDI FT232H device with the device description "Prototypical". This then establishes a unix domain socket at a location specified, so for example "sender /tmp/screen.socket". 

The executable is placed in /usr/local/bin, and then screen.service gets placed into /etc/systemd/system/.
