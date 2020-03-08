# Based on the official Docker image
FROM butlerx/wetty:latest

# Default user is 'term' with password 'term'
ENV WEBCONSOLE_USER='term' \
    WEBCONSOLE_HASH='$1$Na5Tk1oW$Vpr1Hkuw7RkI17YU0zM.T/' \
    WEBCONSOLE_SHELL='/bin/sh' \
    WEBCONSOLE_PORT=3000

# Add only the OpenSSH client - This image is a jump host!
RUN apk add --update --no-cache openssh-client && \
    rm /etc/motd

COPY ./entrypoint.sh ./
RUN chmod 755 ./entrypoint.sh

EXPOSE ${WEBCONSOLE_PORT}

ENTRYPOINT [ "./entrypoint.sh" ]
CMD [ "node", "." ]
