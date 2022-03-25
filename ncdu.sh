#!/bin/sh
# filename:     ncdu.sh
# author:       Graham Inggs
# date:         2018-05-24 ; Initial release for NAS4Free 11.1.0.4
# date:         2018-12-29 ; Updated for XigmaNAS 11.2.0.4
# date:         2019-10-29 ; Updated for XigmaNAS 12.0.0.4 (no changes)
# date:         2019-11-25 ; Updated for XigmaNAS 12.1.0.4
# date:         2021-04-03 ; Updated for XigmaNAS 12.2.0.4
# author:       nivigor
# date:         2022-03-25 ; Updated for XigmaNAS 12.*; not need exact file names
# purpose:      Install NCurses Disk Usage (ncdu) on XigmaNAS (embedded version).
# Note:         Check the end of the page.
#
#----------------------- Set variables ------------------------------------------------------------------
DIR=`dirname $0`;
NCDUFILE="ncdu-*"
#----------------------- Set Errors ---------------------------------------------------------------------
_msg() { case $@ in
  0) echo "The script will exit now."; exit 0 ;;
  1) echo "No route to server, or file do not exist on server"; _msg 0 ;;
  2) echo "Can't find ${FILE} on ${DIR}"; _msg 0 ;;
  3) echo "NCurses Disk Usage installed and ready! (ONLY USE DURING A SSH SESSION)"; exit 0 ;;
  4) echo "Always run this script using the full path: /mnt/.../directory/ncdu.sh"; _msg 0 ;;
esac ; exit 0; }
#----------------------- Check for full path ------------------------------------------------------------
if [ ! `echo $0 |cut -c1-5` = "/mnt/" ]; then _msg 4; fi
cd $DIR;
#----------------------- Download and decompress ncdu files if needed -----------------------------------
FILE=${NCDUFILE}
if [ ! -d ${DIR}/usr/local/bin ]; then
  if [ ! -e ${DIR}/${FILE} ]; then pkg fetch -y ncdu;
    cp `find /var/cache/pkg/ -name ${FILE} -not -name "*~*"` ${DIR} || _msg 1; fi
  if [ -f ${DIR}/${FILE} ]; then tar xzf ${DIR}/${FILE} || _msg 2; rm /var/cache/pkg/*;
    rm ${DIR}/+*; rm -R ${DIR}/usr/local/man; rm -R ${DIR}/usr/local/share; fi
  if [ ! -d ${DIR}/usr/local/bin ] ; then _msg 4; fi
fi
#----------------------- Create wrapper script to enable experimental color support ---------------------
if [ ! -e ${DIR}/usr/local/bin/ncdu.real ]; then
  mv ${DIR}/usr/local/bin/ncdu ${DIR}/usr/local/bin/ncdu.real
  cat <<'EOF' >${DIR}/usr/local/bin/ncdu
#!/bin/sh
/usr/local/bin/ncdu.real --color dark "$@"
EOF
  chmod +x ${DIR}/usr/local/bin/ncdu
fi
#----------------------- Create symlinks ----------------------------------------------------------------
for i in `ls $DIR/usr/local/bin/`
  do if [ ! -e /usr/local/bin/${i} ]; then ln -s ${DIR}/usr/local/bin/$i /usr/local/bin; fi; done
_msg 3 ; exit 0;
#----------------------- End of Script ------------------------------------------------------------------
# 1. Keep this script in its own directory.
# 2. chmod the script u+x,
# 3. Always run this script using the full path: /mnt/.../directory/ncdu.sh
# 4. You can add this script to WebGUI: Advanced: Command Scripts as a PostInit command (see 3).
# 5. To run Ncurses Disk Usage from shell type 'ncdu'.
