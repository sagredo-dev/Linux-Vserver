vserver newserver \
	build -m rsync \
	--context 12115 \
        --hostname newserver.yourdomain.tld \
        --interface eth0:10.0.0.2 \
        -- --source oldserver
