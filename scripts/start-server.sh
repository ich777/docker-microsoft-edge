#!/bin/bash
export DISPLAY=:99
export XAUTHORITY=${DATA_DIR}/.Xauthority

CUR_V="$(${DATA_DIR}/bin/microsoft-edge --version 2>/dev/null | cut -d ' ' -f3)"
if [ "${MS_EDGE_V}" == "latest" ]; then
  LAT_V="$(wget -qO- https://packages.microsoft.com/repos/edge/pool/main/m/microsoft-edge-stable/ | grep -oP '(?<=href=").*?(?=">)' | awk -F'>' '{print $1}' | grep '^[a-zA-Z]' | sort -V | tail -1)"
  if [ -z "${LAT_V}" ]; then
    if [ -z "${CUR_V}" ]; then
      echo "Something went horribly wrong with version detection!"
	  echo "Can't get latest version and found no current installed version!"
	  echo "Putting container into sleep mode..."
      sleep infinity
	else
	  echo "Couldn't get latest version from Microsoft-Edge, falling back to installed version: ${CUR_V}"
	  LAT_V="${CUR_V}"
    fi
  fi
else
  LAT_V="${MS_EDGE_V}"
fi

if [ -d ${DATA_DIR}/temp ]; then
  rm -rf ${DATA_DIR}/temp
fi

if [ -z "${CUR_V}" ]; then
  echo "---Microsoft Edge not installed, please wait installing...---"
  mkdir -p ${DATA_DIR}/temp ${DATA_DIR}/bin
  cd ${DATA_DIR}/temp
  if wget -q -nc --show-progress --progress=bar:force:noscroll -O ${DATA_DIR}/temp/ms-edge-$LAT_V.deb "https://packages.microsoft.com/repos/edge/pool/main/m/microsoft-edge-stable/microsoft-edge-stable_${LAT_V}-1_amd64.deb" ; then
    echo "---Sucessfully downloaded Microsoft Edge---"
  else
    echo "---Something went wrong, can't download Microsoft Edge, putting container in sleep mode---"
    sleep infinity
  fi
  ar x ${DATA_DIR}/temp/ms-edge-$LAT_V.deb
  tar -xf ${DATA_DIR}/temp/data.tar.xz
  mv ${DATA_DIR}/temp/opt/microsoft/msedge/* ${DATA_DIR}/bin/
  rm -rf ${DATA_DIR}/temp
elif [ "${CUR_V}" != "${LAT_V}" ]; then
  echo "---Version missmatch, please wait installing latest version: ${LAT_V}...---"
  mkdir -p ${DATA_DIR}/temp
  cd ${DATA_DIR}/temp
  if wget -q -nc --show-progress --progress=bar:force:noscroll -O ${DATA_DIR}/temp/ms-edge-$LAT_V.deb "https://packages.microsoft.com/repos/edge/pool/main/m/microsoft-edge-stable/microsoft-edge-stable_${LAT_V}-1_amd64.deb" ; then
    echo "---Sucessfully downloaded Microsoft Edge---"
  else
    echo "---Something went wrong, can't download Microsoft Edge, falling back to installed version: ${CUR_V}---"
    rm -rf ${DATA_DIR}/temp
    break
  fi
  rm -rf ${DATA_DIR}/bin
  mkdir -p ${DATA_DIR}/bin
  ar x ${DATA_DIR}/temp/ms-edge-$LAT_V.deb
  tar -xf ${DATA_DIR}/temp/data.tar.xz
  mv ${DATA_DIR}/temp/opt/microsoft/msedge/* ${DATA_DIR}/bin/
  rm -rf ${DATA_DIR}/temp
elif [ "${CUR_V}" == "${LAT_V}" ]; then
  echo "---Microsoft Edge v${CUR_V} up-to-date---"
fi

echo "---Resolution check---"
if [ -z "${CUSTOM_RES_W}" ]; then
  CUSTOM_RES_W=1024
fi
if [ -z "${CUSTOM_RES_H}" ]; then
  CUSTOM_RES_H=768
fi

if [ "${CUSTOM_RES_W}" -le 1023 ]; then
  echo "---Width to low must be a minimal of 1024 pixels, correcting to 1024...---"
  CUSTOM_RES_W=1024
fi
if [ "${CUSTOM_RES_H}" -le 767 ]; then
  echo "---Height to low must be a minimal of 768 pixels, correcting to 768...---"
  CUSTOM_RES_H=768
fi
echo "---Checking for old logfiles---"
find $DATA_DIR -name "XvfbLog.*" -exec rm -f {} \;
find $DATA_DIR -name "x11vncLog.*" -exec rm -f {} \;
echo "---Checking for old display lock files---"
rm -rf /tmp/.X99*
rm -rf /tmp/.X11*
rm -rf ${DATA_DIR}/.vnc/*.log ${DATA_DIR}/.vnc/*.pid ${DATA_DIR}/Singleton*
chmod -R ${DATA_PERM} ${DATA_DIR}
if [ -f ${DATA_DIR}/.vnc/passwd ]; then
	chmod 600 ${DATA_DIR}/.vnc/passwd
fi
screen -wipe 2&>/dev/null

echo "---Starting TurboVNC server---"
vncserver -geometry ${CUSTOM_RES_W}x${CUSTOM_RES_H} -depth ${CUSTOM_DEPTH} :99 -rfbport ${RFB_PORT} -noxstartup ${TURBOVNC_PARAMS} 2>/dev/null
sleep 2
echo "---Starting Fluxbox---"
screen -d -m env HOME=/etc /usr/bin/fluxbox
sleep 2
echo "---Starting noVNC server---"
websockify -D --web=/usr/share/novnc/ --cert=/etc/ssl/novnc.pem ${NOVNC_PORT} localhost:${RFB_PORT}
sleep 2

echo "---Starting Microsoft Edge---"
cd ${DATA_DIR}/bin
if [ "${DEBUG}" != "true" ]; then
  ${DATA_DIR}/bin/microsoft-edge --user-data-dir=${DATA_DIR}/profile --disable-accelerated-video --disable-gpu --dbus-stub --no-sandbox --test-type ${EXTRA_PARAMETERS} 2>/dev/null
else
  ${DATA_DIR}/bin/microsoft-edge --user-data-dir=${DATA_DIR}/profile --disable-accelerated-video --disable-gpu --dbus-stub --no-sandbox --test-type ${EXTRA_PARAMETERS}
fi