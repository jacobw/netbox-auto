FROM ghcr.io/netbox-community/netbox:v4.7.1

COPY plugin_requirements.txt /opt/netbox/
RUN /usr/local/bin/uv pip install -r /opt/netbox/plugin_requirements.txt

# Plugins are enabled at runtime by the Helm chart's `plugins:` value.
# Enable them here only for collectstatic, which bakes any plugin static
# assets into the image and doubles as a build-time compatibility check
# (the plugin must import cleanly against this NetBox version). plugins.py
# is removed afterwards so runtime PLUGINS stays chart-driven.
RUN echo "PLUGINS = ['netbox_bgp']" > /etc/netbox/config/plugins.py \
    && DEBUG="true" SECRET_KEY="dummydummydummydummydummydummydummydummydummydummy" \
       /opt/netbox/venv/bin/python /opt/netbox/netbox/manage.py collectstatic --no-input \
    && rm -f /etc/netbox/config/plugins.py
