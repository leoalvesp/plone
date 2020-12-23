FROM python:3.8-slim-buster

ENV PIP=20.2.3 \
    ZC_BUILDOUT=2.13.3 \
    SETUPTOOLS=50.3.0 \
    WHEEL=0.35.1 \
    PLONE_MAJOR=5.2 \
    PLONE_VERSION=5.2.2 \
    PLONE_VERSION_RELEASE=Plone-5.2.2-UnifiedInstaller \
    PLONE_MD5=a603eddfd3abb0528f0861472ebac934

LABEL plone=$PLONE_VERSION \
    os="debian" \
    os.version="10" \
    name="Plone 5.2" \
    description="Plone image, based on Unified Installer" \
    maintainer="Plone Community"

ADD https://raw.githubusercontent.com/plone/plone.docker/master/5.2/5.2.2/debian/buildout.cfg /plone/instance/

ADD https://raw.githubusercontent.com/plone/plone.docker/master/5.2/5.2.2/debian/docker-initialize.py /

COPY docker-entrypoint.sh /

RUN mkdir -p /plone/instance/ /data/filestorage /data/blobstorage \
 && buildDeps="dpkg-dev gcc libbz2-dev libc6-dev libffi-dev libjpeg62-turbo-dev libopenjp2-7-dev libpcre3-dev libssl-dev libtiff5-dev libxml2-dev libxslt1-dev wget zlib1g-dev" \
 && runDeps="git gosu libjpeg62 libopenjp2-7 libtiff5 libxml2 libxslt1.1 lynx netcat poppler-utils rsync wv" \
 && apt-get update \
 && apt-get install -y --no-install-recommends $buildDeps \
 && wget -O Plone.tgz https://launchpad.net/plone/$PLONE_MAJOR/$PLONE_VERSION/+download/$PLONE_VERSION_RELEASE.tgz \
 && echo "$PLONE_MD5 Plone.tgz" | md5sum -c - \
 && tar -xzf Plone.tgz \
 && cp -rv ./$PLONE_VERSION_RELEASE/base_skeleton/* /plone/instance/ \
 && cp -v ./$PLONE_VERSION_RELEASE/buildout_templates/buildout.cfg /plone/instance/buildout-base.cfg \
 && pip install pip==$PIP setuptools==$SETUPTOOLS zc.buildout==$ZC_BUILDOUT wheel==$WHEEL \
 && cd /plone/instance \
 && buildout \
 && ln -s /data/filestorage/ /plone/instance/var/filestorage \
 && ln -s /data/blobstorage /plone/instance/var/blobstorage \
 && rm -rf /Plone* \
 && apt-get purge -y --auto-remove $buildDeps \
 && apt-get install -y --no-install-recommends $runDeps \
 && rm -rf /var/lib/apt/lists/* \
 && rm -rf /plone/buildout-cache/downloads/* \
 && chmod g+x /docker-entrypoint.sh && chmod g=u /docker-initialize.py

VOLUME /data

EXPOSE 8080
WORKDIR /plone/instance

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["start"]
