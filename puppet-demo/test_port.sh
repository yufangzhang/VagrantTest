port=$(sudo netstat -taupen | grep nginx | grep -v tcp6| awk '{print $4}' | awk -F ":" '{print $2}')
if [ "$port"=="80" ]; then
	echo "Nginx is listening on port 80"
else 
	echo "Nginx fails to listen on port 80"
fi

