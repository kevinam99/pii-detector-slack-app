# PII Detector Application Documentation

## Overview

The PII Detector is an Elixir application that monitors Slack channels and Notion databases for messages or tickets containing Personally Identifiable Information (PII). When PII is detected, the application removes the content and notifies the author via Slack DM, asking them to recreate it without the sensitive information.

## Features

- **Slack Integration**: Monitors specified Slack channels for messages containing PII
- **Notion Integration**: Monitors specified Notion databases for tickets containing PII. Please note that the Notion alerts are instantaneous as Slack becuase Notion takes some time to send the webhook.
- **PII Detection**: Uses pattern matching and AI (OpenAI) to detect PII in text, images, and PDFs. Added minimum support for multimedia files but the urls received from the webhook for multimedia files don't allow downloading files programmatically to check their contents so cannot check for PII there. There is no Notion API endpoint to delete a post in a database so auto deletion is not included.
- **Automatic Content Removal**: Deletes messages/tickets containing PII. However, messages cannot be deleted on Slack via API because the action is not allowed
- **User Notification**: Sends DMs to users with their original content for easy recreation
- **Monitoring**: Includes telemetry for tracking detection events and performance

## Setup Instructions

### Prerequisites

- Elixir 1.17.3-otp-27
- Erlang/OTP 27.1.2
- Slack workspace with admin privileges
- Notion workspace with admin privileges

### Environment variables
 - SLACK_CLIENT_SECRET
 - SLACK_SIGNING_SECRET
 - SLACK_VERIFICATION_TOKEN
 - SLACK_API_TOKEN
 - NOTION_API_TOKEN
 - CLOUDFLARE_ACCOUNT_ID
 - CLOUDFLARE_API_TOKEN


### Slack Setup

1. Create a Slack app at https://api.slack.com/apps
2. Add the following OAuth scopes:
   - `channels:history` - To read messages
   - `channels:read` - To identify channels
   - `chat:write` - To send DMs
   - `chat:write.public` - To send messages in channels
   - `files:read` - To read file content
   - `users:read` - To get user information
   - `users:read.email` - To find users by email
3. Install the app to your workspace
4. Copy the Bot User OAuth Token to `SLACK_API_TOKEN`
5. Copy the Signing Secret to `SLACK_SIGNING_SECRET`
6. Add the app to the channels you want to monitor
7. Set up an Event Subscription with the URL: `https://your-app-url.com/slack/events`
8. Subscribe to the `message.channels` event

### Notion Setup

1. Create an integration at https://www.notion.so/my-integrations
2. Copy the Internal Integration Token to `NOTION_API_TOKEN`
3. Share the databases you want to monitor with the integration
4. Copy the database IDs to `NOTION_DATABASE_IDS`


### Deployment
I deployed this to Gigalixir because it just makes it very easy and I am used to the platform

## Testing the Application

### Testing Slack Integration

1. Send a message containing PII (e.g., "My SSN is 123-45-6789") in one of the watched channels
2. The message should be deleted and you should receive a DM with your original message
3. Send a message without PII - it should remain in the channel

### Testing Notion Integration

1. Create a page in a watched database containing PII
2. The page should be deleted and you should receive a Slack DM with the original content
3. Create a page without PII - it should remain in the database

## Architecture

The application is built with a modular architecture:

- **Slack Integration**: Handles Slack events, message processing, and API interactions
- **Notion Integration**: Handles Notion database monitoring, page processing, and API interactions
- **PII Detection**: Analyzes content for PII using pattern matching and AI
- **Message Handler**: Coordinates the flow of content through the system

## Troubleshooting

- **Slack messages not being processed**: Verify the bot is in the channel and has the correct permissions
- **Notion pages not being processed**: Verify the integration has access to the database
- **PII not being detected**: Check the OpenAI API key and ensure the AI service is available
- **Application not starting**: Check the logs for errors and verify all environment variables are set correctly
