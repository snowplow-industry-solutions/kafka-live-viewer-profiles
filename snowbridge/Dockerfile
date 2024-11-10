FROM snowplow/snowbridge:3.0.0
USER root
RUN apk add --no-cache bash grep sed coreutils
WORKDIR /app
COPY run.sh /app/run.sh
RUN chmod +x /app/run.sh
RUN chown -R snowplow: /app
USER snowplow
ENTRYPOINT ["/app/run.sh"]
