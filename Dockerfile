FROM docker.io/library/archlinux:base-devel

LABEL ver="1"

COPY ca.pem /ca.pem
COPY entrypoint.sh /entrypoint.sh
RUN echo '[multilib]' >> /etc/pacman.conf && echo 'Include = /etc/pacman.d/mirrorlist' >> /etc/pacman.conf && \
    sed -i 's/ParallelDownloads = 5/ParallelDownloads = 10/g' /etc/pacman.conf && \
    mkdir -p /etc/gnupg && \
    echo "auto-key-retrieve" >> /etc/gnupg/gpg.conf && \
    echo 'Server = https://pacman_cache.aurum.lan/$repo/os/$arch' > /etc/pacman.d/mirrorlist && \
    trust anchor /ca.pem && update-ca-trust && rm /ca.pem && \
    pacman-key --init && \
    pacman --noconfirm -Syu git gnupg base-devel && \
    pacman --noconfirm -Scc && \
    mkdir -p /run/user/1000 && chown 1000:1000 /run/user/1000 && \
    echo '%wheel ALL=(ALL:ALL) NOPASSWD: ALL' >> /etc/sudoers && \
    useradd --uid 1000 --shell /bin/bash --groups wheel --create-home aur && \
    chmod +x /entrypoint.sh

USER aur
WORKDIR /home/aur

ENTRYPOINT ["/entrypoint.sh"]
