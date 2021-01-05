#!/bin/sh

theme=$1
DIR="$HOME/tendenci"
SITE="mysite"

TENDENCI="$HOME/tendenci/tendenci/bin/"
SITE_LOC="$HOME/tendenci/tendenci/bin/$SITE"
THEME_BASE="$HOME/tendenci/tendenci/bin/$SITE/themes/t7-base"
THEME_2020="$HOME/tendenci/tendenci/bin$SITE/themes/t7-tendenci2020"

create_project() {
    cd $TENDENCI &&
        exec python3 tendenci.py startproject mysite
}

install_theme() {
    echo "Installing t7-base theme..."
    cp -r "$HOME/tendenci/tendenci/themes/t7-base" "$THEME_BASE"
}

if [ -d "$DIR" ]; then
    echo "Tendenci folder exists in your home directory"
    echo "Checking for an existing project"
    if [ -d "$SITE_LOC" ]; then
        echo "Project has already been started"
        echo "Checking for a theme folder in project"
        if [ -d "$THEME_BASE" ]; then
            echo "Project is configured with the t7-base theme"
        elif [ -d "$THEME_2020" ]; then
            echo "Project is configured with the t7-tendenci2020 theme"
        else
            echo "Project does not have a theme installed. Installing theme t7-base...."
            install_theme
        fi
    else
        (create_project)
        (install_theme)
    fi
else
    echo "Tendenci folder does not exist in your home directory"
    git clone https://github.com/tendenci/tendenci "$HOME/tendenci"
    (create_project)
    (install_theme)
fi

echo "Finished, starting the docker-compose..."

docker-compose up
trap "docker-compose down" EXIT
