ssh -T ubuntu@11.0.2.154 <<	EOF
    Firstdomname=`echo "$Domain_Name" | cut -d"." -f1`          || exit 1
    Seconddomname=`echo "$Domain_Name" | cut -d"." -f2`         || exit 1
    Thirddomname=`echo "$Domain_Name" | cut -d"." -f3`          || exit 1
    LowerFirstdomname=`echo "$Firstdomname" | tr '[:upper:]' '[:lower:]'`         || exit 1
    LowerSeconddomname=`echo "$Seconddomname" | tr '[:upper:]' '[:lower:]'`         || exit 1
    dtc_upper=$(echo "'$Firstdomname'-'$Seconddomname'-UI'" | tr '[:lower:]' '[:upper:]')         || exit 1
    dtc_lower=$(echo "$Domain_Name" | tr '[:upper:]' '[:lower:]')         || exit 1
    eval dtc_site_name="$LowerSeconddomname"         || exit 1
    echo "$dtc_site_name"        || exit 1
    echo "$dtc_lower"         || exit 1
    cd /home/ubuntu/.constants         || exit 1
    mkdir "$dtc_site_name"         || exit 1
    ll "$dtc_site_name"            || exit 1
    cp -R koan/* "$dtc_site_name"/.         || exit 1
    cd "$dtc_site_name"         || exit 1
    mv koan.sh "$dtc_site_name".sh         || exit 1
    #sed -e 's/shop.koan.life/"$dtc_lower"/g' koan.Dockerfile > $dtc_site_name.Dockerfile         || exit 1
    rm -rf koan.Dockerfile         || exit 1
EOF