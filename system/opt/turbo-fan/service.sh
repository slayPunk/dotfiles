KERNELVERSION="7.1.8-1-cachyos"
cd /opt/turbo-fan

rm /dev/acer-gkbbl-0 /dev/acer-gkbbl-static-0 -f

if [ "$(uname -r)" != "$KERNELVERSION" ] || [ ! -f /opt/turbo-fan/src/facer.ko ]; then
	make clean
    source ./install.sh
	sed -i "s/^KERNELVERSION.*/KERNELVERSION=\"$(uname -r)\"/" /opt/turbo-fan/service.sh
else
	rmmod acer_wmi
	rmmod facer
	modprobe wmi
	modprobe sparse-keymap
	modprobe video
	insmod /opt/turbo-fan/src/facer.ko
fi
