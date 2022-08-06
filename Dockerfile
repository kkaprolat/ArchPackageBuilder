FROM docker.io/library/archlinux:base-devel

LABEL ver="1"

COPY ca.pem /ca.pem
COPY build_package.py /build_package.py

RUN echo '[multilib]' >> /etc/pacman.conf && echo 'Include = /etc/pacman.d/mirrorlist' >> /etc/pacman.conf && \
    sed -i 's/ParallelDownloads = 5/ParallelDownloads = 10/g' /etc/pacman.conf && \
    mkdir -p /etc/gnupg && \
    echo "auto-key-retrieve" >> /etc/gnupg/gpg.conf && \
    echo 'Server = https://pacman_cache.aurum.lan/$repo/os/$arch' > /etc/pacman.d/mirrorlist && \
    trust anchor /ca.pem && update-ca-trust && rm /ca.pem && \
    pacman-key --init && \
    pacman --noconfirm -Syu git gnupg base-devel python python-requests wget && \
    pacman --noconfirm -Scc && \
    mkdir -p /run/user/1000 && chown 1000:1000 /run/user/1000 && \
    echo '%wheel ALL=(ALL:ALL) NOPASSWD: ALL' >> /etc/sudoers && \
    useradd --uid 1000 --shell /bin/bash --groups wheel --create-home aur && \
    chmod +x /build_package.py && \
    git config --global user.email "kakaoh6@gmail.com" && \
    git config --global user.name "Kay Kaprolat"

USER aur
WORKDIR /home/aur

ENTRYPOINT ["/build_package.py"]
