# creates ssl certs for Helicone ingress configuration
nginx:
	chmod +x nginx_setup.sh
	./nginx_setup.sh

# install Helicone chart via upgrade in default namespace
helicone:
	helm upgrade helicone . --install -f values.example.yaml -n default

# uninstall Helicone chart from default namespace
uninstall:
	helm uninstall helicone -n default