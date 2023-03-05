#!/bin/bash

set -x
set -e

OUT_DIR="$1"
BBB_MLO="$2"
BBB_UBOOT_IMG="$3"
BBB_UPDATE="$4"
EPC_UPDATE="$5"
PLAYCONTROLLER_UPDATE="$6"

SOURCE_DIR="$OUT_DIR"

UPDATE_EPC="1"
UPDATE_BBB="1"
UPDATE_PLAYCONTROLLER="1"
ASPECTS="playcontroller epc bbb"

OUT_TAR=$OUT_DIR/nonlinear-c15-update.tar

OUT_DIRECTORY=/tmp/nonlinear-c15-update

fail_and_exit() {
    echo "Failed to created an update!"
    exit 1
}

check_preconditions () {
    if [ -z "$EPC_UPDATE" -a "$UPDATE_EPC" = "1" ]; then echo "ePC update missing..." && return 1; fi
    if [ -z "$BBB_UPDATE" -a "$UPDATE_BBB" = "1" ]; then echo "BBB update missing..." && return 1; fi
    if [ -z "$PLAYCONTROLLER_UPDATE" -a "$UPDATE_PLAYCONTROLLER" = "1" ]; then echo "playcontroller update missing..." && return 1; fi
    return 0
}

create_update_file_structure() {
    echo "Creating Update Structure..."
    rm -rf $OUT_DIRECTORY
    mkdir $OUT_DIRECTORY || fail_and_exit
    if [ "$UPDATE_BBB" = "1" ]; then mkdir $OUT_DIRECTORY/BBB || fail_and_exit; fi
    if [ "$UPDATE_EPC" = "1" ]; then mkdir $OUT_DIRECTORY/EPC || fail_and_exit; fi
    if [ "$UPDATE_PLAYCONTROLLER" = "1" ]; then mkdir $OUT_DIRECTORY/playcontroller || fail_and_exit; fi
    mkdir $OUT_DIRECTORY/utilities || fail_and_exit
    echo "Creating Update Structure done."
    return 0
}

deploy_updates() {
    echo "Deploying updates..."

    if [ "$UPDATE_BBB" = "1" ]; then
        echo "Will deploy BBB updates."
        cp $BBB_UPDATE $OUT_DIRECTORY/BBB/rootfs.tar || fail_and_exit;
        gzip $OUT_DIRECTORY/BBB/rootfs.tar || fail_and_exit;
        chmod 666 $OUT_DIRECTORY/BBB/rootfs.tar.gz || fail_and_exit;

        cp $BBB_MLO $OUT_DIRECTORY/BBB/MLO && chmod 666 $OUT_DIRECTORY/BBB/MLO || fail_and_exit;
        cp $BBB_UBOOT_IMG $OUT_DIRECTORY/BBB/u-boot.img && chmod 666 $OUT_DIRECTORY/BBB/u-boot.img || fail_and_exit;

        SUM=$(md5sum $OUT_DIRECTORY/BBB/MLO)
        echo $SUM | cut -d' ' -f1 >> $OUT_DIRECTORY/BBB/MLO_sum

        SUM=$(md5sum $OUT_DIRECTORY/BBB/u-boot.img)
        echo $SUM | cut -d' ' -f1 >> $OUT_DIRECTORY/BBB/UBOOT_sum
    fi

    if [ "$UPDATE_EPC" = "1" ]; then
        echo "Will deploy ePC updates."
        cp $EPC_UPDATE $OUT_DIRECTORY/EPC/update.tar && chmod 666 $OUT_DIRECTORY/EPC/update.tar || fail_and_exit;
    fi

    if [ "$UPDATE_PLAYCONTROLLER" = "1" ]; then
        echo "Will deploy playcontroller update."
        cd /tmp
        tar -x -f $PLAYCONTROLLER_UPDATE
        ar -x /tmp/playcontroller-firmware.deb data.tar.gz
        tar -xf /tmp/data.tar.gz
        cp /tmp/usr/local/bin/playcontroller-firmware-main.bin $OUT_DIRECTORY/playcontroller/main.bin && chmod 666 $OUT_DIRECTORY/playcontroller/main.bin || fail_and_exit;
    fi

    echo "Deploying updates done."
    return 0
}

deploy_scripts() {
    echo "Deploying update scripts..."

    cp $SOURCE_DIR/update_scripts/run.sh $OUT_DIRECTORY/ && chmod 777 $OUT_DIRECTORY/run.sh || fail_and_exit;
    sed -i "s/ASPECTS=\"TO_BE_REPLACED_BY_CREATE_C15_UPDATE\"/ASPECTS=\"$ASPECTS\"/g" $OUT_DIRECTORY/run.sh

    cp $SOURCE_DIR/update_scripts/at-least-version-22-42.stamp $OUT_DIRECTORY/ || fail_and_exit;

    if [ "$UPDATE_BBB" = "1" ]; then
        cp $SOURCE_DIR/update_scripts/bbb_update.sh $OUT_DIRECTORY/BBB/ && \
            chmod 777 $OUT_DIRECTORY/BBB/bbb_update.sh || \
            fail_and_exit;
    fi

    if [ "$UPDATE_EPC" = "1" ]; then
        cp $SOURCE_DIR/update_scripts/epc_pull_update.sh $OUT_DIRECTORY/EPC/ && \
            chmod 777 $OUT_DIRECTORY/EPC/epc_pull_update.sh && \
            cp $SOURCE_DIR/update_scripts/epc_1_fix.sh $OUT_DIRECTORY/EPC/ && \
            chmod 777 $OUT_DIRECTORY/EPC/epc_1_fix.sh && \
            cp $SOURCE_DIR/update_scripts/epc_2_fix.sh $OUT_DIRECTORY/EPC/ && \
            chmod 777 $OUT_DIRECTORY/EPC/epc_2_fix.sh || \
            fail_and_exit;
    fi

    if [ "$UPDATE_PLAYCONTROLLER" = "1" ]; then
        cp $SOURCE_DIR/update_scripts/playcontroller_update.sh $OUT_DIRECTORY/playcontroller/ && \
            chmod 777 $OUT_DIRECTORY/playcontroller/playcontroller_update.sh && \
            cp $SOURCE_DIR/update_scripts/playcontroller_check.sh $OUT_DIRECTORY/playcontroller/ && \
            chmod 777 $OUT_DIRECTORY/playcontroller/playcontroller_check.sh || \
            fail_and_exit;
    fi

    echo "Deploying update scripts done."

    echo "Creating run.sh dummys..."
    if [ -e $OUT_DIRECTORY/run_v2.sh ] && [ -L $OUT_DIRECTORY/run_v2.sh ]; then
        rm -f $OUT_DIRECTORY/run_v2.sh
    fi
    if [ -e $OUT_DIRECTORY/run_v3.sh ] && [ -L $OUT_DIRECTORY/run_v3.sh ]; then
        rm -f $OUT_DIRECTORY/run_v3.sh
    fi
    touch $OUT_DIRECTORY/run_v2.sh && chmod 777 $OUT_DIRECTORY/run_v2.sh
    touch $OUT_DIRECTORY/run_v3.sh && chmod 777 $OUT_DIRECTORY/run_v3.sh
    echo "Creating run.sh dummys done"

    return 0
}

get_tools_from_rootfs() {
    echo "Getting tools from rootfs..."
    
    mkdir /tmp/rootfs && tar -xf $BBB_UPDATE --exclude=./dev/* -C /tmp/rootfs

    for i in mxli sshpass text2soled rsync socat thttpd playcontroller mke2fs; do
        if ! cp $(find /tmp/rootfs -type f -name "$i" | head -n 1) $OUT_DIRECTORY/utilities/; then
          echo "could not get $i from rootfs"
          return 1
        fi
    done

    for i in sshpass text2soled rsync socat thttpd mxli playcontroller mke2fs; do
        if ! chmod +x $OUT_DIRECTORY/utilities/"$i"; then
          echo "could not make $i executable"
          return 1
        fi
    done

    for lib in libpopt.so.0.0.0 libpopt.so.0 libpopt.so; do
        if ! cp $(find /tmp/rootfs/lib/ -name "$lib") $OUT_DIRECTORY/utilities/; then
               echo "could not get library $lib from rootfs"
          return 1
        fi
    done

    if ! cp -R /tmp/rootfs/usr/local/share/text2soled $OUT_DIRECTORY/utilities/resources; then
        echo "could not get text2soled resources"
        return 1
    fi

    echo "Getting tools from rootfs done."
    return 0
}


create_update_tar () {
    echo "Creating $OUT_TAR..."
    rm -rf $OUT_DIRECTORY/../nonlinear-c15-update.tar
    if cd $OUT_DIRECTORY/ && tar -cf $OUT_TAR * ; then
        echo "Creating $OUT_TAR done."
        return 0
    fi
    echo "Creating $OUT_TAR failed."
    return 1
}

main() {
    check_preconditions || fail_and_exit
    create_update_file_structure || fail_and_exit
    deploy_updates || fail_and_exit
    deploy_scripts || fail_and_exit
    get_tools_from_rootfs || fail_and_exit
    create_update_tar || fail_and_exit
}

main
