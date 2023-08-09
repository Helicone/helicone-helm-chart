# Makefile

# Target to setup nginx
nginx:
	chmod +x nginx_setup.sh
    ./nginx_setup.sh

helicone:
	helm -n default install helicone -f values.example.yaml .

down:
	helm uninstall helicone -n default


.PHONY: setup_nginx helicone uninstall
