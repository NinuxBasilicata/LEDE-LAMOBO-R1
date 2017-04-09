#/bin/bash -x
compile=`pwd`
#version='custom/config-base'
version='custom/config-nodogspash'


if [ -d source ]; then
	cd source && git pull
fi
if [ ! -d source ]; then
        git clone https://github.com/lede-project/source.git
fi
if [ -d Firmware ]; then
        rm -rf Firmware
fi
if [ ! -d Firmware ]; then
        mkdir Firmware
fi

cat $compile/feeds.conf > $compile/source/feeds.conf.default
cat $compile/custom/etc/banner > $compile/source/package/base-files/files/etc/banner
cp -R $compile/custom/etc/config $compile/source/package/base-files/files/etc/
cp $compile/custom/etc/uci-defaults/* $compile/source/package/base-files/files/etc/uci-defaults/
cd $compile/source
./scripts/feeds update -a && ./scripts/feeds install -a && \
cat $compile/$version > $compile/source/.config && \
make V=s -j 5 >&1 | tee build.log | egrep -i '(warn|error)'  && \
mv $compile/source/bin/targets/sunxi/generic/*.img.gz $compile/Firmware/ && \
mv $compile/source/bin/targets/sunxi/generic/config.seed $compile/Firmware/

make clean && make dirclean
