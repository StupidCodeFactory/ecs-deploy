#!/bin/sh

set +e
set -x

error() {
    printf "✖ %s\n" "$@"
}

warn() {
    printf "➜ %s\n" "$@"
}

type_exists() {
    if [ $(type -P $1) ]; then
        return 0
    fi
    return 1
}

if ! type_exists 'ruby'; then
    error "Please install ruby or use a docker ruby image"
fi

INSTALL_BUNDLER=$(gem install bundler --no-doc 2>&1)
if [ $? -ne 0 ]; then
    error "Unable to install bundler"
    warn "$INSTALL_BUNDLER"
    exit 1
fi

INSTALL_DEPENDENCIES=$(bundle install --without test --gemfile=$WERCKER_STEP_ROOT/Gemfile 2>&1)

if [ $? -ne 0 ]; then
    error "Unable to install dependencies"
    warn "$INSTALL_DEPENDENCIES"
    exit 1
fi

if [ -z "${WERCKER_ECS_DEPLOY_CLUSTER_NAME}" ]; then
    error "Please set the 'cluster_name' key under the stupidcodefactory/ecs-deploy step definition."
    exit 1
fi

if [ -z "${WERCKER_ECS_DEPLOY_AUTOSCALING_GROUP_FILE}" ]; then
    error "Please set the 'autoscaling-group-file' key under the stupidcodefactory/ecs-deploy step definition."
    exit 1
fi

if [ -z "${WERCKER_ECS_DEPLOY_LAUNCH_CONFIGURATION_FILE}" ]; then
    error "Please set the 'launch-configuration-file' key under the stupidcodefactory/ecs-deploy step definition."
    exit 1
fi

if [ -z "${WERCKER_ECS_DEPLOY_TASK_DEFINITION_FILE}" ]; then
    error "Please set the 'task-definition-file' key under the stupidcodefactory/ecs-deploy step definition."
    exit 1
fi

if [ -z "${WERCKER_ECS_DEPLOY_SERVICES_FILE}" ]; then
    error "Please set the 'services-file' key under the stupidcodefactory/ecs-deploy step definition."
    exit 1
fi

bundle exec ruby $WERCKER_STEP_ROOT/main.rb \
       -c $WERCKER_ROOT/$$WERCKER_ECS_DEPLOY_CLUSTER_NAME \
       -a $WERCKER_ROOT/$WERCKER_ECS_DEPLOY_AUTOSCALING_GROUP_FILE \
       -l $WERCKER_ROOT/$WERCKER_ECS_DEPLOY_LAUNCH_CONFIGURATION_FILE \
       -t $WERCKER_ROOT/$WERCKER_ECS_DEPLOY_TASK_DEFINITION_FILE \
       -s $WERCKER_ROOT/$WERCKER_ECS_DEPLOY_SERVICES_FILE
