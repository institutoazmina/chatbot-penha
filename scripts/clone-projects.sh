#!/bin/bash
set -e

# o usuario precisa ter acesso ao docker
docker -v

basepath=
while true ; do
    read -r -p "Digite o diretório para guardar os dados e código fonte dos serviços: " basepath
    if [ -d "$basepath" ] ; then
        break
    fi
    echo "$basepath não é um diretório válido..."
done

dbname=
while true ; do
    read -r -p "Digite um nome para o banco de dados: " dbname
    valid='^[a-z][0-9a-z_]+$'
    if [[ $dbname =~ $valid ]] ; then
        break
    fi
    echo "$dbname não é um nome válido. utilize apenas a-z 0-9 e underline"
done

MY_PATH=$(pwd)

set -x

echo "preparando repositórios em $basepath..."

cp $MY_PATH/env.base $basepath/.env
cp $MY_PATH/docker-compose.yml $basepath/

perl -pi -w -e "s|_BASEDIR_|$basepath|g;" $basepath/.env
perl -pi -w -e "s|_DBNAME_|$dbname|g;" $basepath/.env
perl -pi -w -MDigest::MD5 -e 's|random-value-here|Digest::MD5::md5_hex(rand().rand().rand().rand())|ge;' $basepath/.env



cd $basepath

mkdir $basepath/src

git clone https://github.com/revistaazmina/penha_webhook_twitter.git $basepath/src/penha_webhook_twitter
git clone https://github.com/revistaazmina/penha_arvore_decisao.git $basepath/src/penha_arvore_decisao
git clone https://github.com/revistaazmina/penha_analytics.git $basepath/src/penha_analytics

echo "criando diretorios para os dados persistentes..."
mkdir -p $basepath/data/webhook_log/
mkdir -p $basepath/data/quiz_api/log/

# as pastas de dados e código precisam ser escritas pelo user 1000:1000
sudo chown 1000:1000 $basepath/data/ -R
sudo chown 1000:1000 $basepath/src/penha_arvore_decisao -R

echo "fazendo build das imagens (leva um bom tempo!)..."
cd $basepath/src/penha_arvore_decisao/api
./build-container.sh

cd $basepath
docker-compose build

echo "Build completado. Configure o arquivo $basepath/.env com as chaves do twitter e outros parametros."

