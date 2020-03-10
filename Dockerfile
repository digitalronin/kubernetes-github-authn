FROM alpine:3.4

RUN apk --no-cache --update add ca-certificates

COPY _output/main /boot

RUN addgroup -g 1000 -S appgroup && \
    adduser -u 1000 -S appuser -G appgroup

USER 1000

CMD ["/boot"]
