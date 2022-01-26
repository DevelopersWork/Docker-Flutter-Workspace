# Usage: <script_name>.sh <IP_ADDRESS> <PORT>

if [ $# -eq 0 ]
  then
    echo "Usage: <script_name>.sh <IP_ADDRESS> <PORT>"
    exit 1
fi
if [ -z "$1" ]
  then
    echo "Usage: <script_name>.sh <IP_ADDRESS> <PORT>"
    exit 1
fi
port=$2
if [ -z "$2" ]
  then
    port="5555"
fi

adb connect $1:$port
adb devices
