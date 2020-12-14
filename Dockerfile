# Dockerfile

FROM docker

ENV awscli 2.0.47
ENV awsauth 0.3.0
ENV helm v3.2.4
ENV kubectl v1.19.5
ENV terraform 0.14.2

ENV rubygems 3.0.6

RUN apk add -v --update python3 python3-dev py3-pip bash curl git jq openssh perl busybox-extras zip unzip ruby build-base ruby-dev

RUN gem install atlassian-stash --no-document 

RUN apk del build-base ruby-dev

RUN curl -sLO https://storage.googleapis.com/kubernetes-release/release/${kubectl}/bin/linux/amd64/kubectl && \
    chmod +x kubectl && mv kubectl /usr/local/bin/kubectl

RUN curl -sL https://get.helm.sh/helm-${helm}-linux-amd64.tar.gz | tar xz && \
    mv linux-amd64/helm /usr/local/bin/helm

RUN curl -sLO https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/download/v${awsauth}/heptio-authenticator-aws_${awsauth}_linux_amd64 && \
    chmod +x heptio-authenticator-aws_${awsauth}_linux_amd64 && mv heptio-authenticator-aws_${awsauth}_linux_amd64 /usr/local/bin/aws-iam-authenticator

RUN curl -sLO https://releases.hashicorp.com/terraform/${terraform}/terraform_${terraform}_linux_amd64.zip && \
    unzip terraform_${terraform}_linux_amd64.zip && \
    rm -f terraform_${terraform}_linux_amd64.zip && \
    mv terraform /usr/local/bin/terraform

### aws cli v2
ENV GLIBC_VER=2.32-r0

# install glibc compatibility for alpine
RUN apk --no-cache add \
        binutils \
        curl \
    && curl -sL https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub -o /etc/apk/keys/sgerrand.rsa.pub \
    && curl -sLO https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VER}/glibc-${GLIBC_VER}.apk \
    && curl -sLO https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VER}/glibc-bin-${GLIBC_VER}.apk \
    && apk add --no-cache \
        glibc-${GLIBC_VER}.apk \
        glibc-bin-${GLIBC_VER}.apk \
    && curl -sL https://awscli.amazonaws.com/awscli-exe-linux-x86_64-${awscli}.zip -o awscliv2.zip \
    && unzip awscliv2.zip \
    && aws/install \
    && rm -rf \
        awscliv2.zip \
        aws \
        /usr/local/aws-cli/v2/*/dist/aws_completer \
        /usr/local/aws-cli/v2/*/dist/awscli/data/ac.index \
        /usr/local/aws-cli/v2/*/dist/awscli/examples \
    && apk --no-cache del \
        binutils \
        curl \
    && rm glibc-${GLIBC_VER}.apk \
    && rm glibc-bin-${GLIBC_VER}.apk \
    && rm -rf /var/cache/apk/*

VOLUME /root/.aws


ENTRYPOINT ["bash"]
