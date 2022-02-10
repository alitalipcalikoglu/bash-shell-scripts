#!/bin/bash

# Colors
RESET='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
LIGHTCYAN='\033[1;36m'

echo -e "${GREEN}Cattr for Docker installer"
echo -e "${RESET}We will ask you a few questions to configure your shiny new Cattr instance\n"

## HTTPS
echo -ne "> Should we enable HTTPS for your instance? (yes/no):${LIGHTCYAN} "
read HTTPS
if [ "$HTTPS" = 'yes' ] || [ "$HTTPS" = 'y' ]; then
  HTTPS="true"
  FRONTEND_APP_URL="https:"
else
  if [ "$HTTPS" = 'no' ] || [ "$HTTPS" = 'n' ]; then
    HTTPS="false"
  fi
  FRONTEND_APP_URL="http:"
fi

echo -ne "${RESET}> Enter domain for this installation (e.g. ${ORANGE}cattr.acme.corp${RESET}):${LIGHTCYAN} "
read FRONTEND_DOMAIN

## Administrator credentials
echo -ne "${RESET}> Administrator name (e.g. ${ORANGE}John Doe${RESET}): ${LIGHTCYAN}"
read ADMIN_NAME
echo -ne "${RESET}> Administrator email (e.g. ${ORANGE}john@acme.corp${RESET}): ${LIGHTCYAN}"
read ADMIN_MAIL
echo -ne "${RESET}> Administrator password (input is hidden for security): "
read -s ADMIN_PASSWORD
echo -ne "\n> Repeat administrator password (input is hidden for security): "
read -s ADMIN_PASSWORD_VERIFY

if [ $ADMIN_PASSWORD != $ADMIN_PASSWORD_VERIFY ]; then
  echo -e "${RED}passwords don't match${RESET}"
  exit 1
else
  echo -e "${GREEN}password match${RESET}"
fi

echo -ne "> Do you want to enable Cattr auto-update? (yes/no):${LIGHTCYAN} "
read UPDATE

echo -e "\nStarting installation\n"

# Creating volumes
docker volume create cattr-ssl
docker volume create cattr-db
docker volume create cattr-screenshots
docker volume create cattr-config

# Start container
docker run -d -it --restart always -p 5000:80 -p 5001:443 --name cattr \
  -v cattr-db:/var/lib/mysql \
  -v cattr-screenshots:/app/backend/storage/app/uploads/screenshots \
  -v cattr-ssl:/etc/letsencrypt \
  -v cattr-config:/app/backend/bootstrap/cache \
  -e FRONTEND_DOMAIN="$FRONTEND_DOMAIN" \
  -e ADMIN_MAIL="$ADMIN_MAIL" \
  -e HTTPS="$HTTPS" \
  -e MAIL_FROM_ADDRESS="no-reply@$FRONTEND_DOMAIN" \
  -e FRONTEND_APP_URL="$FRONTEND_APP_URL//$FRONTEND_DOMAIN" \
  amazingcat/cattr || exit 1

# Registering admin account
echo -e "\n${GREEN}Docker container was deployed, waiting for a moment to register your admin account${RESET}"
sleep 10
docker exec -it cattr sh -c "/app/install.sh $ADMIN_NAME $ADMIN_PASSWORD" || exit 1

if [ "$UPDATE" = 'yes' ] || [ "$UPDATE" = 'y' ]; then
  echo -e "\nTrying to register auto-updater"

  mkdir -p ~/.cattr
  wget https://dl.cattr.app/installer/updater.sh -O ~/.cattr/updater.sh
  chmod 764 ~/.cattr/updater.sh

  crontab -l | { cat; echo "0 * * * * bash ~/.cattr/updater.sh >> /dev/null 2>&1"; } | crontab -
else
  echo -e "\nIf you want to update cattr you should run this command: \"curl -sSL https://dl.cattr.app/installer/cattr-update.sh | bash -\""
fi

# Exit
echo -e "\n${GREEN}Installation is done, thank you!${RESET}"
