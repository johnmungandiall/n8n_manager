# n8n Manager

This script automates the process of starting an n8n instance and exposing it to the internet using localtunnel.

## Features

- **Automated Setup**: Checks for Node.js and npm dependencies.
- **Public URL**: Uses localtunnel to create a public URL for your local n8n instance, making webhooks accessible from the internet.
- **Configuration**: Easily configure the n8n port and localtunnel subdomain.
- **Environment Setup**: Automatically sets the necessary environment variables for n8n to work with the tunnel.
- **Persistent Data**: Stores n8n data in the same directory as the script.

## Prerequisites

- [Node.js](https://nodejs.org/) and npm must be installed and available in your system's PATH.

## Configuration

You can modify the following variables at the beginning of the `start.bat` script:

- `N8N_PORT`: The local port on which n8n will run (default: `8080`).
- `LT_SUBDOMAIN`: The desired subdomain for your localtunnel URL (e.g., `my-n8n-instance-12433`). This must be unique.

## Usage

1.  (Optional) Modify the configuration variables in `start.bat` as needed.
2.  Double-click `start.bat` to run the script.
3.  A new window will open for localtunnel. Wait for the script to retrieve the public URL.
4.  The public URL for your n8n instance will be displayed in the console.
5.  n8n will start, and you can access it locally at `http://localhost:8080` (or your configured port).
6.  The script will automatically configure n8n to use the public URL for webhooks.
