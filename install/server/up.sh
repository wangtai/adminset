#!/bin/bash
set -e
main_dir="/var/opt/adminset"
adminset_dir="$main_dir/main"
data_dir="$main_dir/data"
config_dir="$main_dir/config"
logs_dir="$main_dir/logs"
cd "$( dirname "$0"  )"
cd .. && cd ..
cur_dir=$(pwd)
cd $adminset_dir
pip install -r requirements.txt

cd $adminset_dir
if [ $1 ]
then
    python manage.py makemigrations $1
    python manage.py migrate
else
    python manage.py makemigrations
    python manage.py migrate
fi
echo "####update celery####"
mkdir -p $config_dir/celery
scp $adminset_dir/install/server/celery/beat.conf $config_dir/celery/beat.conf
scp $adminset_dir/install/server/celery/celery.service /usr/lib/systemd/system
scp $adminset_dir/install/server/celery/start_celery.sh $config_dir/celery/start_celery.sh
scp $adminset_dir/install/server/celery/beat.service /usr/lib/systemd/system
chmod +x $config_dir/celery/start_celery.sh
scp $adminset_dir/install/server/nginx/adminset.conf /etc/nginx/conf.d
scp $adminset_dir/install/server/nginx/nginx.conf /etc/nginx
nginx -s reload
echo "##############install finished###################"
systemctl daemon-reload
nginx -s reload
service adminset restart
service beat restart
service celery restart
echo "you have updated adminset successfully!!!"
echo "################################################"
