#! /bin/bash
print_help_and_exit() {
    echo "Usage: $0 [-h] [-r] [-s stage]" >&2
    echo "  -h:       Print help" >&2
    echo "  -r:       Remove containers" >&2
    echo "  -s stage: Select stage, either development or production or notoken or debug" >&2
    exit
}

action=up
stage=

while getopts hrs: arg; do
    case ${arg} in
        h)
            print_help_and_exit
            ;;
        r)
            action=rm
            ;;
        s)
            stage=${OPTARG}
            ;;
    esac
done

[[ -z ${stage} ]] && print_help_and_exit

docker-compose \
    -f docker-compose.yml \
    -f docker-compose.${stage}.yml \
    ${action}
