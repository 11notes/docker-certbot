# ------ HEADER ------ #
FROM 11notes/nginx:latest
ARG DEBIAN_FRONTEND=noninteractive

# ------ RUN  ------ #
ADD ./source/certbot.conf /var/nginx/conf.d/certbot.conf
ADD ./source/certbot.sh /usr/local/bin/certbot-run
RUN chmod +x /usr/local/bin/certbot-run

WORKDIR /opt/certbot
ENV PATH /opt/certbot/venv/bin:$PATH

RUN export BUILD_DEPS="git \
                build-base \
                libffi-dev \
                linux-headers \
                py-pip \
                python-dev" \
    && apk -U upgrade \
    && apk add dialog \
                python \
                openssl-dev \
				augeas-libs \
                ${BUILD_DEPS} \
				openssl \
	&& pip install --upgrade pip \
    && pip --no-cache-dir install virtualenv \
    && git clone https://github.com/letsencrypt/letsencrypt /opt/certbot/src \
    && virtualenv --no-site-packages -p python2 /opt/certbot/venv \
    && /opt/certbot/venv/bin/pip install \
        -e /opt/certbot/src/acme \
        -e /opt/certbot/src \
        -e /opt/certbot/src/certbot-apache \
        -e /opt/certbot/src/certbot-nginx \ 
    && apk del ${BUILD_DEPS} \
    && rm -rf /var/cache/apk/* \
	&& certbot --version

# :: Version
RUN echo "radicale version: app.version{{$(certbot --version)}}"

# ------ VOLUMES ------ #
VOLUME ["/var/ssl"]

# ------ CMD/START/STOP ------ #
STOPSIGNAL SIGTERM
CMD ["nginx", "-g", "daemon off;"]