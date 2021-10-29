# Install and configure a single-node LiveKit server on Fly.io

[LiveKit](https://livekit.io/) is an open source platform for real-time communication (WebRTC) based on the [Pion](https://pion.ly/) Go WebRTC stack. This example allows you to easily run a single-node LiveKit server on [Fly.io](https://fly.io/) hosting. This can be used to run a personal server for my [LiveKit AVClient Module](https://github.com/bekriebel/fvtt-module-avclient-livekit) for [FoundryVTT](https://foundryvtt.com/).

To provide a better reconnection mechanism with LiveKit, [redis](https://redis.io/) is also deployed to Fly. The redis steps can optionally be skipped, however users may not automatically reconnect if there is an interruption to the WebSocket connection during a session.

Note that this implementation does not allow you to scale to multiple LiveKit servers due to Fly only providing a single BGP Anycast ipv4 address per application. There are ways to accomplish this with Fly, but it is not the topic of this example.

## Prerequisites

A functioning [Docker](https://www.docker.com/) installation on the machine you will be deploying from.

## Install and configure flyctl

1. Follow Fly's QuickStart guide: [Installing flyctl](https://fly.io/docs/getting-started/installing-flyctl/)
1. Follow Fly's QuickStart guide: [Login to Fly](https://fly.io/docs/getting-started/login-to-fly/)

## Launch redis on Fly

1. Switch to the [redis](redis/) folder and review the configuration files. No changes should be needed.
1. Init a new Fly app for redis  
   `flyctl apps create`
1. Create an app name, or let one be auto-generated. Remember this name for later steps, indicated with \<REDIS_APP_NAME\>
1. Determine your primary region, listed as **Region Pool**. Remember this for later steps, indicated with \<REGION\>  
   `fly -a <REDIS_APP_NAME> regions list`
1. Create a persistent volume for your redis app  
   `fly -a <REDIS_APP_NAME> volumes create livekit_redis --region <REGION>`
1. Add a secure password as an application secret to secure redis. I recommend randomly generating a string for this. Remember this for later steps, indicated with \<YOUR_REDIS_PASSWORD\>  
   `fly -a <REDIS_APP_NAME> secrets set REDIS_PASSWORD=<YOUR_REDIS_PASSWORD>`
1. Deploy the redis app from from the [redis](redis/) path  
   `fly -a <REDIS_APP_NAME> deploy`

## Launch LiveKit on Fly

1. Switch to the [livekit](livekit/) folder and review the configuration files. No changes should be needed.
1. Init a new fly app for LiveKit  
   `flyctl apps create`
1. Create an app name, or let one be auto-generated. Remember this name for later steps, indicated with \<LIVEKIT_APP_NAME\>
1. Set the region to match your redis app  
   `fly -a <LIVEKIT_APP_NAME> regions set <REGION>`
1. Generate an API key/secret pair (for more information, see LiveKit's guide: [Generate API key and secret](https://docs.livekit.io/guides/getting-started#generate-api-key-and-secret))  
   `docker run --rm livekit/livekit-server generate-keys`
1. Note the generated key/secret pair for use in later steps, indicated with \<API_KEY\> and \<SECRET_KEY\>
1. Add the LiveKit key/secret pair as an application secret on LiveKit  
   `fly -a <LIVEKIT_APP_NAME> secrets set LIVEKIT_KEYS="<API_KEY>: <SECRET_KEY>"`
1. Add the redis host as an application secret on LiveKit  
   `fly -a <LIVEKIT_APP_NAME> secrets set REDIS_HOST=<REDIS_APP_NAME>.internal:6379`
1. Add the redis password as an application secret on LiveKit  
   `fly -a <LIVEKIT_APP_NAME> secrets set REDIS_PASSWORD=<YOUR_REDIS_PASSWORD>`
1. Deploy the LiveKit app from the [livekit](livekit/) path  
   `fly -a <LIVEKIT_APP_NAME> deploy`
1. Congratulations! LiveKit is now running at `<LIVEKIT_APP_NAME>.fly.dev` with yor API key/secret pair. Note that since we are using the Fly load balancer, which provides SSL termination, the sever is running under secure websockets (`wss://`) on port `443`

From here, you can continue to configure the app however you would like. For example, you can add a custom domain by following Fly's documentation [Custom Domains for SaaS](https://fly.io/docs/app-guides/custom-domains-with-fly/).

## Support my work

[![Become a Patron](https://img.shields.io/badge/support-patreon-orange.svg?logo=patreon)](https://www.patreon.com/bekit)
[![Donate via Ko-Fi](https://img.shields.io/badge/donate-ko--fi-red.svg?logo=ko-fi)](https://ko-fi.com/bekit)
