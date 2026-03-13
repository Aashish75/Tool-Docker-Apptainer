# CyVerse entrypoint: set up iRODS env and start Jupyter so gateway routing works.
mkdir -p $HOME/.irods
touch $HOME/.irods/irods_environment.json
echo '{"irods_host": "data.cyverse.org", "irods_port": 1247, "irods_user_name": "$IPLANT_USER", "irods_zone_name": "iplant"}' >> $HOME/.irods/irods_environment.json

echo "export PATH=$PATH:/opt/conda/bin:/bin/.dotnet:/bin/.dotnet/tools" >> ~/.bashrc

git clone https://github.com/CU-ESIIL/cyverse-utils.git || true

# Use the image's start-notebook.sh so CyVerse env (JUPYTERHUB_SERVICE_PREFIX, base_url) is applied.
exec /usr/local/bin/start-notebook.sh --ServerApp.token="" --ServerApp.password="" --ServerApp.allow_origin='*'
