FROM docker.io/library/archlinux:base-devel

LABEL ver="1"

COPY ca.pem /ca.pem
COPY update_package.py /update_package.py

RUN echo '[multilib]' >> /etc/pacman.conf && echo 'Include = /etc/pacman.d/mirrorlist' >> /etc/pacman.conf && \
    sed -i 's/ParallelDownloads = 5/ParallelDownloads = 10/g' /etc/pacman.conf && \
    echo 'Server = https://pacman_cache.aurum.lan/$repo/os/$arch' > /etc/pacman.d/mirrorlist && \
    trust anchor /ca.pem && update-ca-trust && rm /ca.pem && \
    pacman-key --init && \
    pacman --noconfirm -Syu git python python-requests wget && \
    pacman --noconfirm -Scc && \
    chmod +x /update_package.py && \
    git config --global user.email "kakaoh6@gmail.com" && \
    git config --global user.name "Kay Kaprolat"

ENTRYPOINT ["/update_package.py"]
