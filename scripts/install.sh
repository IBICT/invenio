#!/usr/bin/env bash
#
# This file is part of Invenio.
# Copyright (C) 2015, 2016 CERN.
#
# Invenio is free software; you can redistribute it
# and/or modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 2 of the
# License, or (at your option) any later version.
#
# Invenio is distributed in the hope that it will be
# useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Invenio; if not, write to the
# Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston,
# MA 02111-1307, USA.
#
# In applying this license, CERN does not
# waive the privileges and immunities granted to it by virtue of its status
# as an Intergovernmental Organization or submit itself to any jurisdiction.

# check environment variables:
if [ -v ${INVENIO_WEB_HOST} ]; then
    echo "[ERROR] Please set environment variable INVENIO_WEB_HOST before runnning this script."
    echo "[ERROR] Example: export INVENIO_WEB_HOST=192.168.50.10"
    exit 1
fi
if [ -v ${INVENIO_WEB_INSTANCE} ]; then
    echo "[ERROR] Please set environment variable INVENIO_WEB_INSTANCE before runnning this script."
    echo "[ERROR] Example: export INVENIO_WEB_INSTANCE=invenio3"
    exit 1
fi
if [ -v ${INVENIO_WEB_VENV} ]; then
    echo "[ERROR] Please set environment variable INVENIO_WEB_VENV before runnning this script."
    echo "[ERROR] Example: export INVENIO_WEB_VENV=invenio3"
    exit 1
fi
if [ -v ${INVENIO_USER_EMAIL} ]; then
    echo "[ERROR] Please set environment variable INVENIO_USER_EMAIL before runnning this script."
    echo "[ERROR] Example: export INVENIO_USER_EMAIL=info@inveniosoftware.org"
    exit 1
fi
if [ -v ${INVENIO_USER_PASS} ]; then
    echo "[ERROR] Please set environment variable INVENIO_USER_PASS before runnning this script."
    echo "[ERROR] Example: export INVENIO_USER_PASS=uspass123"
    exit 1
fi
if [ -v ${INVENIO_POSTGRESQL_HOST} ]; then
    echo "[ERROR] Please set environment variable INVENIO_POSTGRESQL_HOST before runnning this script."
    echo "[ERROR] Example: export INVENIO_POSTGRESQL_HOST=192.168.50.11"
    exit 1
fi
if [ -v ${INVENIO_POSTGRESQL_DBNAME} ]; then
    echo "[ERROR] Please set environment variable INVENIO_POSTGRESQL_DBNAME before runnning this script."
    echo "[ERROR] Example: INVENIO_POSTGRESQL_DBNAME=invenio3"
    exit 1
fi
if [ -v ${INVENIO_POSTGRESQL_DBUSER} ]; then
    echo "[ERROR] Please set environment variable INVENIO_POSTGRESQL_DBUSER before runnning this script."
    echo "[ERROR] Example: INVENIO_POSTGRESQL_DBUSER=invenio3"
    exit 1
fi
if [ -v ${INVENIO_POSTGRESQL_DBPASS} ]; then
    echo "[ERROR] Please set environment variable INVENIO_POSTGRESQL_DBPASS before runnning this script."
    echo "[ERROR] Example: INVENIO_POSTGRESQL_DBPASS=dbpass123"
    exit 1
fi
if [ -v ${INVENIO_REDIS_HOST} ]; then
    echo "[ERROR] Please set environment variable INVENIO_REDIS_HOST before runnning this script."
    echo "[ERROR] Example: export INVENIO_REDIS_HOST=192.168.50.12"
    exit 1
fi
if [ -v ${INVENIO_ELASTICSEARCH_HOST} ]; then
    echo "[ERROR] Please set environment variable INVENIO_ELASTICSEARCH_HOST before runnning this script."
    echo "[ERROR] Example: export INVENIO_ELASTICSEARCH_HOST=192.168.50.13"
    exit 1
fi
if [ -v ${INVENIO_RABBITMQ_HOST} ]; then
    echo "[ERROR] Please set environment variable INVENIO_RABBITMQ_HOST before runnning this script."
    echo "[ERROR] Example: export INVENIO_RABBITMQ_HOST=192.168.50.14"
    exit 1
fi
if [ -v ${INVENIO_WORKER_HOST} ]; then
    echo "[ERROR] Please set environment variable INVENIO_WORKER_HOST before runnning this script."
    echo "[ERROR] Example: export INVENIO_WORKER_HOST=192.168.50.15"
    exit 1
fi

# load virtualenvrapper:
source $(which virtualenvwrapper.sh)

# detect pathname of this script:
scriptpathname=$(cd "$(dirname $0)" && pwd)

# sphinxdoc-create-virtual-environment-begin
mkvirtualenv ${INVENIO_WEB_VENV}
cdvirtualenv
mkdir -p src
cd src
# sphinxdoc-create-virtual-environment-end

# quit on errors and unbound symbols:
set -o errexit
set -o nounset

if [[ "$@" != *"--devel"* ]]; then
# sphinxdoc-install-invenio-full-begin
# FIXME the next pip commands are needed only for invenio<3.0.0a3
pip install invenio-db[postgresql] --pre
pip install invenio-access[postgresql] --pre
pip install invenio-search --pre
pip install dojson --pre
# now we can install full Invenio:
pip install invenio[full] --pre
# sphinxdoc-install-invenio-full-end
else
    pip install -r $scriptpathname/../requirements-devel.txt
fi

# sphinxdoc-create-instance-begin
inveniomanage instance create ${INVENIO_WEB_INSTANCE}
# sphinxdoc-create-instance-end

# sphinxdoc-install-instance-begin
cd ${INVENIO_WEB_INSTANCE}
python setup.py install
# sphinxdoc-install-instance-end

# sphinxdoc-customise-instance-begin
mkdir -p ../../var/${INVENIO_WEB_INSTANCE}-instance/
echo "# Database" > ../../var/${INVENIO_WEB_INSTANCE}-instance/${INVENIO_WEB_INSTANCE}.cfg
echo "SQLALCHEMY_DATABASE_URI='postgresql+psycopg2://${INVENIO_POSTGRESQL_DBUSER}:${INVENIO_POSTGRESQL_DBPASS}@${INVENIO_POSTGRESQL_HOST}:5432/${INVENIO_POSTGRESQL_DBNAME}'" >> ../../var/${INVENIO_WEB_INSTANCE}-instance/${INVENIO_WEB_INSTANCE}.cfg
echo "" >> ../../var/${INVENIO_WEB_INSTANCE}-instance/${INVENIO_WEB_INSTANCE}.cfg
echo "# Redis" >> ../../var/${INVENIO_WEB_INSTANCE}-instance/${INVENIO_WEB_INSTANCE}.cfg
echo "CACHE_REDIS_HOST='${INVENIO_REDIS_HOST}'" >> ../../var/${INVENIO_WEB_INSTANCE}-instance/${INVENIO_WEB_INSTANCE}.cfg
echo "" >> ../../var/${INVENIO_WEB_INSTANCE}-instance/${INVENIO_WEB_INSTANCE}.cfg
echo "# Celery" >> ../../var/${INVENIO_WEB_INSTANCE}-instance/${INVENIO_WEB_INSTANCE}.cfg
echo "BROKER_URL='redis://${INVENIO_REDIS_HOST}:6379/0'" >> ../../var/${INVENIO_WEB_INSTANCE}-instance/${INVENIO_WEB_INSTANCE}.cfg
echo "CELERY_RESULT_BACKEND='redis://${INVENIO_REDIS_HOST}:6379/1'" >> ../../var/${INVENIO_WEB_INSTANCE}-instance/${INVENIO_WEB_INSTANCE}.cfg
echo "CELERY_ALWAYS_EAGER=True" >> ../../var/${INVENIO_WEB_INSTANCE}-instance/${INVENIO_WEB_INSTANCE}.cfg
echo "CELERY_EAGER_PROPAGATES_EXCEPTIONS=True" >> ../../var/${INVENIO_WEB_INSTANCE}-instance/${INVENIO_WEB_INSTANCE}.cfg
echo "" >> ../../var/${INVENIO_WEB_INSTANCE}-instance/${INVENIO_WEB_INSTANCE}.cfg
echo "# Elasticsearch" >> ../../var/${INVENIO_WEB_INSTANCE}-instance/${INVENIO_WEB_INSTANCE}.cfg
echo "SEARCH_ELASTIC_HOSTS='${INVENIO_ELASTICSEARCH_HOST}'" >> ../../var/${INVENIO_WEB_INSTANCE}-instance/${INVENIO_WEB_INSTANCE}.cfg
# sphinxdoc-customise-instance-end

# sphinxdoc-run-npm-begin
cd ${INVENIO_WEB_INSTANCE}
${INVENIO_WEB_INSTANCE} npm
cdvirtualenv var/${INVENIO_WEB_INSTANCE}-instance/static
CI=true npm install
cd -
# sphinxdoc-run-npm-end

# sphinxdoc-collect-and-build-assets-begin
${INVENIO_WEB_INSTANCE} collect -v
${INVENIO_WEB_INSTANCE} assets build
# sphinxdoc-collect-and-build-assets-end

# sphinxdoc-create-database-begin
${INVENIO_WEB_INSTANCE} db init
${INVENIO_WEB_INSTANCE} db create
# sphinxdoc-create-database-end

# sphinxdoc-create-user-account-begin
${INVENIO_WEB_INSTANCE} users create \
       --email ${INVENIO_USER_EMAIL} \
       --password ${INVENIO_USER_PASS} \
       --active
# sphinxdoc-create-user-account-end

# sphinxdoc-start-celery-worker-begin
# FIXME we should run celery worker on another node
# NOTE The celery worker command is not needed since we run
#      with CELERY_ALWAYS_EAGER
# celery worker -A ${INVENIO_WEB_INSTANCE}.celery -l INFO &
# sphinxdoc-start-celery-worker-end

# sphinxdoc-populate-with-demo-records-begin
# discover the location of demo MARC21 record file:
demomarc21pathname=$(echo "from __future__ import print_function; \
import pkg_resources; \
print(pkg_resources.resource_filename('invenio_records', \
  'data/marc21/bibliographic.xml'))" | python)

# count the number of demo MARC21 records:
demomarc21nbrecs=$(grep -c '</record>' $demomarc21pathname)

# convert demo records from MARC21 to JSON and load them
# using randomly generated UUIDs:
demouuids=$(dojson do -i $demomarc21pathname -l marcxml marc21 | \
             ${INVENIO_WEB_INSTANCE} records create \
                $(for i in $(seq 1 $demomarc21nbrecs); \
                   do echo "-i " $(uuid); done))
# sphinxdoc-populate-with-demo-records-end

# sphinxdoc-register-pid-begin
recid=1
for demouuid in $demouuids; do
    ${INVENIO_WEB_INSTANCE} pid create \
         -t rec -i $demouuid -s REGISTERED recid $recid
    let recid=recid+1
done
# sphinxdoc-register-pid-end

# sphinxdoc-start-application-begin
${INVENIO_WEB_INSTANCE} --debug run -h 0.0.0.0 &
# sphinxdoc-start-application-end