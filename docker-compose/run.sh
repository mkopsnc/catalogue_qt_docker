#! /bin/bash
print_help_and_exit() {
    echo "Usage: $0 [-h] [-r] [-s stage]" >&2
    echo "  -h:       Print help" >&2
    echo "  -r:       Remove containers" >&2
    echo "  -s stage: Select stage, either development or production or notoken or debug" >&2
    exit
}

action=up

declare -a stages

while getopts hrs: arg; do
    case ${arg} in
        h)
            print_help_and_exit
            ;;
        r)
            action=rm
            ;;
        s)
            stages+=(${OPTARG})
            ;;
    esac
done

[[ ${#stages[@]} == 0 ]] && print_help_and_exit

DOCKER_COMPOSE_ARG="-f docker-compose.yml"

for i in "${stages[@]}"; do DOCKER_COMPOSE_ARG="${DOCKER_COMPOSE_ARG} -f docker-compose.${i}.yml"; done

docker-compose ${DOCKER_COMPOSE_ARG} ${action}
