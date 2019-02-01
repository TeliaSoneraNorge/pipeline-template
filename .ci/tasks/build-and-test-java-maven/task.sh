#!/bin/sh

set -ueo pipefail
mkdir settings

cat > "settings/settings.xml" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<settings>
	<servers>
        <server>
            <id>netcom-releases</id>
            <username>${username}</username>
            <password>${password}</password>
        </server>
        <server>
            <id>netcom-snapshots</id>
            <username>${username}</username>
            <password>${password}</password>
        </server>
	</servers>
	<localRepository>.m2/repository</localRepository>
    <mirrors>
        <mirror>
            <id>nexus</id>
            <mirrorOf>*</mirrorOf>
            <url>${endpoint}/content/groups/alle/</url>
        </mirror>
    </mirrors>
    <profiles>
        <profile>
            <id>default</id>
            <activation>
                <activeByDefault>true</activeByDefault>
            </activation>
            <repositories>
                <repository>
                    <id>central</id>
                    <url>${endpoint}/content/groups/public/</url>
                    <snapshots>
                        <enabled>false</enabled>
                    </snapshots>
                </repository>
                <repository>
                    <id>snapshots</id>
                    <url>${endpoint}/content/groups/public-snapshot/</url>
                    <releases>
                        <enabled>false</enabled>
                    </releases>
            </repository>
                </repositories>
                <pluginRepositories>
                <pluginRepository>
                    <id>central</id>
                    <url>${endpoint}/content/groups/public/</url>
                    <snapshots>
                        <enabled>false</enabled>
                    </snapshots>
                </pluginRepository>
                <pluginRepository>
                    <id>snapshots</id>
                    <url>${endpoint}/content/groups/public-snapshot/</url>
                    <releases>
                        <enabled>false</enabled>
                    </releases>
                </pluginRepository>
            </pluginRepositories>
        </profile>
    </profiles>
</settings>
EOF

echo "Settings xml written"
echo ""

export GREEN='\033[1;32m'
export NC='\033[0m'
export CHECK="√"
export M2_LOCAL_REPO=".m2"

mkdir -p "${M2_LOCAL_REPO}/repository"

mvn --quiet -f "source/pom.xml" \
    --settings "settings/settings.xml" \
    -Dmaven.wagon.http.ssl.insecure=true \
    -Dmaven.wagon.http.ssl.allowall=true \
    -Dmaven.wagon.http.ssl.ignore.validity.dates=true \
    install
    # | egrep "(^\[ERROR\])"

echo -e "${GREEN}${CHECK} Maven install${NC}"

cp -p source/Dockerfile build-artefacts/
cp -p "$(ls -t source/target/*.jar | grep -v /orig | head -1)" build-artefacts/app.jar
echo -e "${GREEN}${CHECK} Output copied${NC}"