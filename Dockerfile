FROM alpine:latest AS builder

ARG TARGETPLATFORM
RUN apk add --no-cache --virtual .build-deps \
    curl binutils jq \       
 && export VERSION=$(curl -s "https://api.github.com/repos/klzgrad/naiveproxy/releases/latest" | jq -r .tag_name)  \   
 && curl --fail --silent -L https://github.com/klzgrad/naiveproxy/releases/download/${VERSION}/naiveproxy-${VERSION}-openwrt-x86_64.tar.xz | \
    tar xJvf - -C / && mv naiveproxy-* naiveproxy  \
 && apk del .build-deps  
 

FROM alpine:latest

COPY --from=builder /naiveproxy/naive /usr/local/bin/naive
 
RUN [ ! -e /etc/nsswitch.conf ] && echo 'hosts: files dns' > /etc/nsswitch.conf

 
RUN apk --no-cache add iptables ca-certificates bash libstdc++ tzdata &&\
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime &&\
    apk del tzdata &&\
    rm -rf /var/cache/apk/*  
    
CMD ["naive", "config.json" ]
