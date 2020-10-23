#! /bin/bash
while :; do
    echo 'Trying to connect to server:8080...'
    curl -s -o /dev/null server:8080
    if [[ $? -eq 0 ]]; then
        break
    fi
    sleep 3
done

cd /demonstrator-dashboard
python dashboard/settings/create.py && \
    python manage.py makemigrations && \
    python manage.py migrate && \
#    python manage.py loaddata dashboard/fixtures/keycloak.json && \
#    python manage.py keycloak_refresh_realm && \
    exec python manage.py runserver 0:8082
