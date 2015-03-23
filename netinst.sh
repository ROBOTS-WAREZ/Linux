apt-get update;
apt-get dist-upgrade;

apt-get install\
    sudo xorg openbox\
    openjdk-7-jdk openjdk-7-jre icedtea-netx\ # Java
    iceweasel\ # Web Browser & File Viewer
    gimp inkscape blender\ # Graphical Editors (Rasta, Vector, 3D)
    --no-install-recommends --assume-yes\
;
