FROM docker.io/library/archlinux:base-devel

COPY ca.pem /ca.pem
COPY update_package.py /update_package.py
COPY build.py /build.py
COPY deploy.py /deploy.py
COPY entrypoint.sh /entrypoint.sh
COPY key.pub /key.pub

RUN echo '[multilib]' >> /etc/pacman.conf && echo 'Include = /etc/pacman.d/mirrorlist' >> /etc/pacman.conf && \
    sed -i 's/ParallelDownloads = 5/ParallelDownloads = 10/g' /etc/pacman.conf && \
    echo 'Server = https://pacman_cache.aurum.lan/$repo/os/$arch' > /etc/pacman.d/mirrorlist && \
    trust anchor /ca.pem && update-ca-trust && rm /ca.pem && \
    pacman-key --init && \
    pacman-key --add /key.pub && \
    pacman-key --lsign-key 36B0B760D0BC85899E38C2DF1F4C5EB20814A291 && \
    echo '[custom]' >> /etc/pacman.conf && \
    echo 'Server = https://packages.aurum.lan/$repo' >> /etc/pacman.conf && \
    pacman -Sy && \
    sed -i 's/^#de_DE.UTF-8 UTF-8/de_DE.UTF-8 UTF-8/' /etc/locale.gen && \
    sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    sed -iE '\|^NoExtract\s*= !usr/share/\*locales/en|a NoExtract = !usr/share/*locales/de_DE !usr/share/*locales/i18n* !usr/share/*locales/iso*' /etc/pacman.conf && \
    pacman --noconfirm -Syu glibc && \
    pacman --noconfirm --needed -Syu git gnupg python python-requests wget base-devel rsync openssh unzip && \
    pacman --noconfirm -Scc && \
    chmod +x /update_package.py && \
    chmod +x /build.py && \
    chmod +x /deploy.py && \
    chmod +x /entrypoint.sh && \
    useradd --uid 1000 --shell /bin/bash --create-home aur && \
    echo 'aur ALL=(ALL:ALL) NOPASSWD: ALL' >> /etc/sudoers && \
    mkdir -p /etc/gnupg && \
    echo 'auto-key-retrieve' >> /etc/gnupg/gpg.conf

USER aur
COPY --chown=aur aurutils /aurutils
RUN git config --global user.email "nobody@nobody.com" && \
    git config --global user.name "Jenkins" && \
    cd /aurutils && \
    makepkg -si --noconfirm && \
    sudo rm -rf /aurutils
