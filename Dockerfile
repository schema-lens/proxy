FROM nginxinc/nginx-unprivileged:1.31.6-alpine-slim

USER root
COPY --chown=0:0 --chmod=444 ./nginx-main.conf /etc/nginx/nginx.conf
COPY --chown=0:0 --chmod=444 ./nginx.conf /etc/nginx/conf.d/default.conf

RUN rm -rf /docker-entrypoint.d /docker-entrypoint.sh /usr/share/nginx/html \
    && chown -R 0:0 /etc/nginx \
    && chmod -R a-w /etc/nginx \
    && find / -xdev -type f \( -perm -4000 -o -perm -2000 \) -exec chmod a-s '{}' +

USER 101:101
EXPOSE 8080
STOPSIGNAL SIGQUIT
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD ["/bin/busybox", "wget", "-q", "-T", "3", "-O", "/dev/null", "http://127.0.0.1:8081/healthz"]

ENTRYPOINT ["nginx"]
CMD ["-g", "daemon off;"]
