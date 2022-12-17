node {
        def app

        stage('Clone repository') {
                checkout scm
        }

        stage('Build image') {
                app = docker.build("kay/aurbuilder:latest", "--network docker_builds --dns 10.0.3.53 --no-cache --pull .")
        }
}
