node {
        stage('Clone repository') {
                checkout scm
        }

        stage('Build image') {
            def builder = 'my_builder'
            def nginx_ip = '10.0.3.2'
            try {
                sh "docker buildx create --driver-opt network=docker_builds --name ${builder}"
                sh "docker buildx inspect --bootstrap --builder ${builder}"          
            } catch (e) {
                // ignore
            } finally {
                sh "docker buildx build --builder ${builder} --add-host packages.aurum.lan:${nginx_ip} --add-host pacman_cache.aurum.lan:${nginx_ip} -t kay/aurbuilder:latest --no-cache --pull --load ."
                sh "docker buildx stop --builder ${builder}"
                sh "docker buildx rm -f --builder ${builder}"
            }

            
        }
}

