#! /bin/bash
cd /demonstrator-dashboard
cp /docker-entrypoint-properties.d/dashboard-secrets.json dashboard/settings/secrets.json

wait-for-it server:8080 --timeout=0

python dashboard/settings/create.py && \
python manage.py makemigrations && \
python manage.py migrate && \
python manage.py loaddata dashboard/fixtures/keycloak.json && \
python manage.py keycloak_refresh_realm && \
exec python manage.py runserver 0:8082
