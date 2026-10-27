# Local configuration

This repository contains the Mediflo web application and its bundled assets.

Sensitive local files are excluded by `.gitignore`:

- `WEB-INF/config/llm_server_key` (SSH private key)
- `WEB-INF/config/config.properties` and dated configuration backups
- Four NICE authentication JSP files containing credentials

To prepare a new checkout, copy each `.example` file to the same path without the `.example` suffix and supply the required local credentials. Provision the SSH private key separately if needed. Existing local originals are preserved.
