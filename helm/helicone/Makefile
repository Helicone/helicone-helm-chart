# Makefile

# Target to setup nginx
nginx:
	chmod +x nginx_setup.sh
    ./nginx_setup.sh

helicone:
	helm upgrade helicone . --install -f values.example.yaml -n default

uninstall:
	helm uninstall helicone -n default


.PHONY: setup_nginx helicone uninstall
