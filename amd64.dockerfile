# :: Header
	FROM 11notes/nginx:stable

# :: Run
	USER root

	# :: prepare
        RUN set -ex; \
            mkdir -p /certbot; \
            mkdir -p /certbot/etc; \
            mkdir -p /certbot/var;

		RUN set -ex; \
            apk --update --no-cache add \
                yq \
                openssl \
                certbot;

    # :: copy root filesystem changes
        COPY ./rootfs /

    # :: docker -u 1000:1000 (no root initiative)
        RUN set -ex; \
            chown -R nginx:nginx \
				/certbot

# :: Volumes
	VOLUME ["/certbot/etc", "/certbot/var"]