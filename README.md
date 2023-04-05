# Microsoft Edge in Docker optimized for Unraid
Microsoft Edge is a proprietary, cross-platform web browser created by Microsoft.

## Env params
| Name | Value | Example |
| --- | --- | --- |
| DATA_DIR | Folder for Microsoft Edge | /ms-edge |
| MS_EDGE_V | Set to 'latest' and the container will check on each container start if a newer version is available or set a static version (please note that only stable versions are supported by the container) | latest |
| CUSTOM_RES_W | Enter your preferred screen width | 1280 |
| CUSTOM_RES_H | Enter your preferred screen height | 768 |
| UID | User Identifier | 99 |
| GID | Group Identifier | 100 |
| UMASK | Umask value | 0000 |
| DATA_PERM | Data permissions for /ms-edge folder | 770 |

## Run example
```
docker run --name Microsoft-Edge -d \
	-p 8080:8080 \
	--env 'MS_EDGE_V=latest' \
	--env 'CUSTOM_RES_W=1280' \
	--env 'CUSTOM_RES_H=768' \
	--env 'UID=99' \
	--env 'GID=100' \
	--env 'UMASK=000' \
	--env 'DATA_PERM=770' \
	--volume /path/to/microsoft-edge:/ms-edge \
	ich777/microsoft-edge
```
### Webgui address: http://[SERVERIP]:[PORT]/vnc.html?autoconnect=true

## Set VNC Password:
Please be sure to create the password first inside the container, to do that open up a console from the container (Unraid: In the Docker tab click on the container icon and on 'Console' then type in the following):

1) **su $USER**
2) **vncpasswd**
3) **ENTER YOUR PASSWORD TWO TIMES AND PRESS ENTER AND SAY NO WHEN IT ASKS FOR VIEW ACCESS**

Unraid: close the console, edit the template and create a variable with the `Key`: `TURBOVNC_PARAMS` and leave the `Value` empty, click `Add` and `Apply`.

All other platforms running Docker: create a environment variable `TURBOVNC_PARAMS` that is empty or simply leave it empty:
```
    --env 'TURBOVNC_PARAMS='
```

This Docker was mainly edited for better use with Unraid, if you don't use Unraid you should definitely try it!

#### Support Thread: https://forums.unraid.net/topic/83786-support-ich777-application-dockers/