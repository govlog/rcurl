#!/bin/bash

# ce wrapper curl permet de faire une requête http / https sur un domaine en utilisant une autre ip
#
# il gère notamment la normalisation http => https ; www vers non WWW ; et non www vers WWW
# il va dire à curl automatiquement de résoudre la version avec ou sans WWW sur l'ip choisie
# pratique pour les sites ayant un schéma du type  : 
#
# http://toto.com/blah => http://www.toto.com/blah => https://www.toto.com/blah
# peut être appelé avec ou sans scheme ; avec ou sans URI
#
# très pratique pour tester un site derrière un LB avec de la normalisation (http => https (www|) => (|www)
#
# les paramètres par défaut de curl sont "-Ivk -XGET -L" mais peuvent être changé en ajoutant des paramètres : 
#
# Utilisation possible : 
#
# rcurl toto.fr 162.19.31.143
# rcurl http://toto.fr/toto 162.19.31.143
# rcurl https://toto.fr/toto 162.19.31.143
# rcurl toto.fr/test 162.19.31.143 -v -L -IXGET
# rcurl https://toto.fr 162.19.31.143 -vIXGET -L
# rcurl https://toto.fr 162.19.31.143 -kL


DOMAIN=$1
IP=$2
OPT="-Ivk -XGET -L"
args=( "$@" )

if [[ $DOMAIN =~ ^(http|https)://([^/]+)(.*) ]]; then
  scheme=${BASH_REMATCH[1]}
  url=${BASH_REMATCH[2]}
  uri=${BASH_REMATCH[3]}
else
  scheme=http
  if [[ $DOMAIN =~ ^([^/]+)(.*) ]]; then
    url=${BASH_REMATCH[1]}
    uri=${BASH_REMATCH[2]}
  fi
fi

[[ $url =~ www ]] && DOMAIN=${DOMAIN/www./}
[[ $3 != "" ]] && OPT=${args[@]:2}

curl $OPT --resolve ${url}:80:${IP} --resolve ${url}:443:${IP} --resolve www.${url}:80:${IP} --resolve www.${url}:443:${IP} ${scheme}://${url}${uri}
