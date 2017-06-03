FROM node:boron-slim

SHELL ["/bin/bash", "-c"]
# Install Ghost
RUN \
  useradd ghost --home /ghost && \
  apt-get update && apt-get -y install wget unzip git  && \
  cd /tmp && \
  wget -O ghost-latest.zip https://api.hgrg.info/github/repos/TryGhost/Ghost/prereleases/latest/zip && \
  unzip ghost-latest.zip -d /ghost && \
  rm -f ghost-latest.zip && \
  cd /ghost && \
  npm i -g knex-migrator && \
  yarn run init && \
  knex-migrator init && \ 
  apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false -o APT::AutoRemove::SuggestsImportant=false zip git && \
  yarn cache clean && \
  sed -i 's/"type": "ghost"/"type": "password"/' /ghost/core/server/config/env/config.development.json && \
  sed -i 's/"http://localhost:": "http://nightshift.tk:"/' /ghost/core/server/config/env/config.development.json && \
  rm -rf /tmp/npm* && \
  
chown -R ghost:ghost /ghost 
#chown -R ghost:ghost /data /ghost /ghost-override

# Add files.
ADD start.bash /ghost-start

# Set environment variables.
ENV NODE_ENV development

# Define mountable directories.
VOLUME ["/data", "/ghost-override"]

# Define working directory.
WORKDIR /ghost

ENV GHOST_SOURCE /ghost

##############################################################################
# PART ONE
# Use "casper" as our default directory to insert FirePress_Klimax
# casper directory act as our default theme.
# It's hacky but Ghost do not allow assigning a default theme programmatically
# 
# 1) Rename casper
# 2) Then, we have to copy theme FirePress_Klimax in casper DIR later.
# 
##############################################################################
RUN \
echo; echo; echo; \
echo "PART ONE ..."; echo; \

THEME_NAME_FROM="casper"; \
THEME_NAME_INTO="casper-foundation"; \

DIR_THEMES="$GHOST_SOURCE/content/themes"; \
DIR_FROM="$DIR_THEMES/$THEME_NAME_FROM"; \
DIR_INTO="$DIR_THEMES/$THEME_NAME_INTO"; \

echo; echo; echo "List (09) $DIR_THEMES ..."; echo; ls -AlhF $DIR_THEMES; du -sh; echo; \

mv $DIR_FROM $DIR_INTO; \
echo; echo; echo "List (10) $DIR_THEMES ..."; echo; ls -AlhF $DIR_THEMES; du -sh; \


##############################################################################
# PART TWO
# Install/copy FirePress_Klimax into casper
##############################################################################
echo; echo; echo; \
echo "PART TWO ..."; echo; \

THEME_NAME_FROM="FirePress_Klimax"; \
THEME_NAME_INTO="casper"; \

GIT_URL="https://github.com/firepress-org/$THEME_NAME_FROM/archive/master.zip"; \

DIR_FROM="$DIR_THEMES/$THEME_NAME_FROM"; \
DIR_INTO="$DIR_THEMES/$THEME_NAME_INTO"; \


cd $DIR_THEMES; \
wget --no-check-certificate -O master.zip $GIT_URL; \
echo; echo; echo "List (12) $DIR_THEMES ..."; echo; ls -AlhF $DIR_THEMES; du -sh; echo; \

unzip $DIR_THEMES/master.zip; \
echo; echo; echo "List (13) $DIR_THEMES ..."; echo; ls -AlhF $DIR_THEMES; du -sh; echo; \

rm $DIR_THEMES/master.zip; \
echo; echo; echo "List (14) $DIR_THEMES ..."; echo; ls -AlhF $DIR_THEMES; du -sh; echo; \

mv $THEME_NAME_FROM-master $THEME_NAME_INTO; \
echo; echo; echo "List (15) $DIR_THEMES ..."; echo; ls -AlhF $DIR_THEMES; du -sh; echo; \

cd $GHOST_SOURCE; \
echo; echo; echo "List (16) $DIR_INTO ..."; echo; ls -AlhF $DIR_INTO; du -sh; echo; \

echo; echo; echo "Show $THEME_NAME_FROM version (17) ($DIR_INTO)"; echo; \
cat $DIR_INTO/package.json | grep "version";


##############################################################################
# Healthcheck
# I had issues with Ghost being "sleepy". I had to refresh the blog 2 times 
# before it response. With this it fix it like a boss.
##############################################################################
#HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
#CMD curl --fail http://localhost:2368/$ENV_2ND_URL_BLOG/ || exit 1

# Expose ports.
EXPOSE 2368

# Define default command.
CMD ["bash", "/ghost-start"]
CMD ["sh", "-c", "chown -R ghost:ghost /ghost"]

USER ghost
#CMD ["sh", "-c", "NODE_ENV=${NODE_ENV:-production} PORT=$PORT npm start"]
CMD ["sh", "-c", "server__host=0.0.0.0 server__port=$PORT npm start"]