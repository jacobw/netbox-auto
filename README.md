# netbox-auto

Custom NetBox image: the upstream image plus pip-installed plugins. Built by
GitHub Actions and published to `ghcr.io/jacobw/netbox-auto`.

## How it fits together

- **This repo** bakes plugin *code* into the image (NetBox plugins must be
  pip-installed at build time; there is no runtime install).
- The deployment (a [netbox-chart](https://github.com/netbox-community/netbox-chart)
  HelmRelease) points at this image and enables/configures plugins via the
  chart's `plugins:` / `pluginsConfig:` values. Plugin *code* lives here;
  plugin *config* lives with the deployment.

## Version lockstep

The image tag mirrors the NetBox base version (e.g. `v4.6.4`) and must match
the `appVersion` of the deployed chart. Update order:

1. Bump `FROM` here (Renovate PR) and the plugin pins in
   `plugin_requirements.txt` per each plugin's compatibility matrix
   ([netbox-bgp](https://github.com/netbox-community/netbox-bgp/blob/master/COMPATIBILITY.md)).
2. Merge → CI publishes `ghcr.io/jacobw/netbox-auto:<version>`.
3. Bump the chart version and `image.tag` in the HelmRelease.

The build runs `collectstatic` with the plugins enabled, which doubles as a
compatibility smoke test — an incompatible plugin fails the build, not the
pod.

## Plugins

| pip package | module (PLUGINS) |
|-------------|------------------|
| netbox-bgp  | netbox_bgp       |

When adding a plugin: pin it in `plugin_requirements.txt`, add its module
name to the `PLUGINS` line in the Dockerfile collectstatic step, and add it
to `plugins:` in the HelmRelease.

## One-time setup

After the first push, make the GHCR package public (repo → Packages →
netbox-auto → Package settings → Change visibility) so the image can be
pulled without an imagePullSecret.
