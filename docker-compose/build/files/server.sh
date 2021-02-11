#!/bin/bash
while :; do
    echo 'Trying to connect to db:3306'
    nc -z -w1 db 3306
#    curl -s -o /dev/null db:3306
    if [[ $? -eq 0 ]]; then
        break
    fi
    sleep 3
done

cd /catalog_qt_2/server/catalog-ws-server/

if [ -z "$DEBUG" ]; then
    exec mvn spring-boot:run
  else
    # exec mvn spring-boot:run -Dspring-boot.run.jvmArguments="-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:5005"
    # Doesn't work. It does not propagate debug arguments to executable.
    # lsof -i -P -N | grep listen doens't show any listening process on port 5005

    echo "======RUNNING SERVER IN DEBUG MODE======"
    mvn install -DskipTests
    exec java -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:5005 -jar ./target/catalog-ws-server-1.0.0-SNAPSHOT.jar
fi