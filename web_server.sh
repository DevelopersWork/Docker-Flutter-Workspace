sh

#!/bin/bash

# Set the port
PORT=$FLUTTER_WEB_PORT

# Stop any program currently running on the set port
echo 'preparing port' $PORT '...'
fuser -k $PORT/tcp

# switch directories
cd build/web/

# Start the server
echo 'Server starting on port' $PORT '...'
python3 -m http.server $PORT
