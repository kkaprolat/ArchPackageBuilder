node {
        def app

        stage('Clone repository') {
                checkout scm
        }

        stage('Build image') {
                app = docker.build("kay/aurbuilder:latest", "--network docker_builds --no-cache --pull .")
        }
}
