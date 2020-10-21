loop=1
tries=10

while [ $loop == 1 ]; do

  curl -s http://localhost:8080 > /dev/null 2>&1
  retVal=$?

  if [ $retVal -ne 0 ]; then
    sleep 10
    tries=$((tries-1))
    if [ $tries == 0 ]; then
      echo "Failed to connect to Catalog QT server"
      exit 1
    fi
  else
    loop=0
  fi


done

python3 /home/imas/opt/demonstrator-dashboard/dashboard/settings/create.py && \
python3 /home/imas/opt/demonstrator-dashboard/manage.py makemigrations && \
python3 /home/imas/opt/demonstrator-dashboard/manage.py migrate && \
python3 /home/imas/opt/demonstrator-dashboard/manage.py loaddata /home/imas/opt/demonstrator-dashboard/dashboard/fixtures/keycloak.json && \
python3 /home/imas/opt/demonstrator-dashboard/manage.py keycloak_refresh_realm && \
python3 /home/imas/opt/demonstrator-dashboard/manage.py runserver 0:8082 &