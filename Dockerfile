# Based on the official Docker image
FROM butlerx/wetty:latest

# Default user is 'term' with password 'term'
ENV WEBCONSOLE_USER='wetty' \
    WEBCONSOLE_HASH='$1$DtdzYdkU$XXM0/.nA8CdpMAPL8bOTs1' \
    WEBCONSOLE_SHELL='/bin/sh' \
    WEBCONSOLE_PORT=3000

# Add only the OpenSSH client - This image is a jump host!
RUN apk add --update --no-cache openssh-client && \
    rm /etc/motd && \
    chmod 664 /etc/hosts

COPY ./entrypoint.sh ./
RUN chmod 755 ./entrypoint.sh

EXPOSE ${WEBCONSOLE_PORT}

ENTRYPOINT [ "./entrypoint.sh" ]
CMD [ "node", "." ]
