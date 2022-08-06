FROM docker.io/library/archlinux:base-devel

LABEL ver="1"

COPY ca.pem /ca.pem
COPY entrypoint.sh /entrypoint.sh
COPY container_update.sh /update.sh
RUN echo '[multilib]' >> /etc/pacman.conf && echo 'Include = /etc/pacman.d/mirrorlist' >> /etc/pacman.conf && \
    sed -i 's/ParallelDownloads = 5/ParallelDownloads = 10/g' /etc/pacman.conf && \
    mkdir -p /etc/gnupg && \
    echo "auto-key-retrieve" >> /etc/gnupg/gpg.conf && \
    echo 'Server = https://pacman_cache.aurum.lan/$repo/os/$arch' > /etc/pacman.d/mirrorlist && \
    trust anchor /ca.pem && update-ca-trust && rm /ca.pem && \
    pacman-key --init && \
    pacman --noconfirm -Syu git jq pacutils expect vim vifm ninja gnupg unzip && \
    pacman --noconfirm -Scc && \
    mkdir -p /run/user/1000 && chown 1000:1000 /run/user/1000 && \
    echo '[custom]' >> /etc/pacman.conf && \
    echo 'SigLevel = Optional TrustAll' >> /etc/pacman.conf && \
    echo 'Server = file:///repo' >> /etc/pacman.conf && \
    echo '%wheel ALL=(ALL:ALL) NOPASSWD: ALL' >> /etc/sudoers && \
    useradd --uid 1000 --shell /bin/bash --groups wheel --create-home aur && \
    install -d /repo -o aur && \
    install -d /viewdb -o aur && \
    install -d /aurdest -o aur && \
    chmod +x /entrypoint.sh && \
    chmod +x /update.sh


VOLUME ["/repo", "/viewdb", "/aurdest"]

USER aur
WORKDIR /home/aur

RUN git clone https://aur.archlinux.org/aurutils.git && \
    cd aurutils && \
    echo '' && \
    echo '' && \
    echo '----------------- aurutils PKGBUILD -----------------' && \
    cat PKGBUILD && \
    echo '------------------  PKGBUILD END  -------------------' && \
    echo '' && \
    echo '' && \
    makepkg --noconfirm -si && \
    cd .. && \
    rm -rf aurutils && \
    sudo pacman --noconfirm -Scc

COPY --chown=0:0 container_sync-devel.sh /usr/lib/aurutils/aur-sync-devel
RUN sudo chmod +x /usr/lib/aurutils/aur-sync-devel

ENV AUR_SYNC_USE_NINJA=1
ENV AUR_VIEW_DB="/viewdb"
ENV AURDEST="/aurdest"

ENTRYPOINT ["/entrypoint.sh"]
