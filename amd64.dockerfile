# :: Header
	FROM 11notes/nginx:stable

# :: Run
	USER root

	# :: prepare
        RUN set -ex; \
            mkdir -p /certbot; \
            mkdir -p /certbot/etc; \
            mkdir -p /certbot/var; \
            mkdir -p /var/log/letsencrypt;

		RUN set -ex; \
            apk --update --no-cache add \
                yq \
                openssl \
                certbot;

    # :: copy root filesystem changes
        COPY ./rootfs /
        RUN set -ex; \
            chmod +x /usr/local/bin/renew;

    # :: docker -u 1000:1000 (no root initiative)
        RUN set -ex; \
            chown -R nginx:nginx \
				/certbot \
                /var/log/letsencrypt;

# :: Volumes
	VOLUME ["/certbot/etc", "/certbot/var"]

# :: Start
	RUN set -ex; chmod +x /usr/local/bin/entrypoint.sh
	USER nginx
	ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]