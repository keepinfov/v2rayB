FROM mzz2017/git:alpine AS version
WORKDIR /build
ADD .git ./.git
RUN git describe --abbrev=0 --tags 2>/dev/null || echo "v0.0.0" | tee ./version

FROM node:lts-alpine AS builder-web
ADD ngui /build/ngui
WORKDIR /build/ngui
RUN npm ci && npm run generate

FROM golang:alpine AS builder
ADD service /build/service
WORKDIR /build/service
COPY --from=version /build/version ./
COPY --from=builder-web /build/ngui/.output/public server/router/web
RUN export VERSION=$(cat ./version) && \
    CGO_ENABLED=0 go build -ldflags="-X github.com/v2rayA/v2rayA/conf.Version=${VERSION:1} -s -w" -o v2rayb .

FROM v2fly/v2fly-core
COPY --from=builder /build/service/v2rayb /usr/bin/
RUN wget -O /usr/local/share/v2ray/LoyalsoldierSite.dat https://raw.githubusercontent.com/mzz2017/dist-v2ray-rules-dat/master/geosite.dat
RUN apk add --no-cache iptables ip6tables tzdata
LABEL org.opencontainers.image.source=https://github.com/keepinfov/v2rayB
EXPOSE 2017
VOLUME /etc/v2rayb
ENTRYPOINT ["v2rayb"]
