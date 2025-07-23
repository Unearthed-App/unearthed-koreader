# Unearthed KOReader Plugin for Obsidian Syncing

Seamlessly sync your KOReader highlights and notes to Obsidian via Unearthed.app. This plugin is a simple one, it's just here to get those highlights and notes off your device and sync them to places that you might want them. So that they aren't locked and lost on whatever device you're using. So that you can combine them with highlights and notes from other sources too. Unearthed can also sync Kindle highlights automatically and merge them with your KOReader highlights. This plugin enables you to maintain an organised collection of your reading insights in one place. This is accomplished by using unearthed.app as a middle man. Each piece of software in the process is open source, so please inspect the code or even run it yourself if you like.

_After the setup is complete, you will **not** need to physically plug in your KOReader device to perform a sync!_ ( ͡° ͜ʖ ͡°)

**Note:** Unearthed can also facilitate syncing to places beyond Obsidian. You can also just sync to [Unearthed.app](https://unearthed.app) and digest the knowledge there if you like.

So far, only tested with:

- KOReader version: 2025.04
- On a Boox Palma

## Features (on unearthed.app)
#### Probably easier to just look at unearthed.app but here are some...
- Sync highlights and notes from KOReader to Obsidian (and other places)
- Daily Reflections built from your highlights and notes, emailed to you.
- Merge highlights from both Kindle and KOReader for the same books
- Tag books, highlights and notes to connect ideas
- AI-powered tagging and idea extraction (if you choose to use it)
- Customisable obsidian templates for book and highlight formatting
- Smart sync that only adds new highlights
- Interactive graph view of books, highlights and tags
#### Obsidian Specific Features
- Customise how books and highlights appear in Obsidian
- Receive daily reflections appended to your daily obsidian note
- See [Unearthed Obsidian Github](https://github.com/Unearthed-App/unearthed-obsidian) for more

## Prerequisites

- An Unearthed.app account with Premium subscription
- KOReader installed on your device
- Obsidian connected to Unearthed.app via an API key (this is a free feature of Unearthed). Follow the instructions here: [Unearthed Obsidian Github](https://github.com/Unearthed-App/unearthed-obsidian)

## Installation

1. Create an account on [unearthed.app](https://unearthed.app)
2. Subscribe to Unearthed Premium (required for KOReader integration)
3. Go to [Releases](https://github.com/Unearthed-App/unearthed-koreader/releases) and download the zip file for latest release
4. Connect your device via USB and navigate to `koreader/plugins` folder
5. Unzip the file into `koreader/plugins` folder, making sure that the parent folder still remains (e.g., `koreader/plugins/Unearthed.koplugin`)
6. On your device, restart KOReader and then go to tools and see if 'Unearthed' is listed as a menu item. If it is not listed there, go to Tools → MoreTools → PluginManagement and make sure 'Unearthed' is enabled
7. Open Tools → Unearthed → Settings and keep it open
8. Select 'Book Location' and input the path to the folder that holds your books along with your books' metadata. This must be the absolute path. You can find it by navigating your device's file system from within the KOReader app. Then look at the top of the app under the word KOReader to see the actual path. Here's an example for an Android device `/storage/emulated/0/Books`
9. Login to Unearthed.app, go to settings and create an API Key, name it whatever you like. Copy it immediately and paste it into **API Key** in the KOReader Unearthed plugin settings
10. Login to Unearthed.app, go to settings (general) and press the copy button next to 'User ID' and paste it into **User ID** in the KOReader Unearthed plugin settings
11. Exit settings, and go back into Tools → Unearthed → SendBooks and then wait
12. Wait until a confirmation message appears. This may take a while if you have many books. Go to Unearthed.app books page and confirm that Unearthed received your books and highlights


## Settings

- **Book Location**: The folder that holds your books along with your books' metadata. Only one location is supported at this time
- **API Key**: A unique Unearthed API key for authentication
- **User ID**: Your unique User ID
- **Auto-sync**: Enable/disable automatic syncing of highlights. When enabled, the plugin will send your highlights to Unearthed.app when you first open KOReader, once per day

## Syncing with Obsidian

After you have your KOReader syncing to Unearthed.app, Follow the instructions here to send that data to Obsidian: [Unearthed Obsidian Github](https://github.com/Unearthed-App/unearthed-obsidian)

## Troubleshooting
#### Potential Problems

- **Highlights not syncing**: This plugin currently only works for books in one location. Make sure your books live within a single folder on your device
- **Latest Highlights are missing**: KOReader doesn't update the metadata until you exit the book. Before forcing a sync, make sure that you have closed all books first
- **Plugin not loading**: Restart KOReader and check Tools → MoreTools → PluginManagement
- **Settings not saving**: Ensure you have write permissions in the plugin directory
- **Sync errors**: Check the debug log for detailed error messages

### Getting Help

If you encounter any issues:

1. Check the debug logs in KOReader's plugin directory
2. Verify your API key and user ID are correct
3. Ensure you have an active Premium subscription
4. Contact through [unearthed.app](https://unearthed.app)
5. Visit [GitHub repository](https://github.com/unearthed-app)

## Contributing

I welcome contributions! The plugin is open source, and I encourage community participation. Feel free to:

- Submit pull requests
- Report issues
- Suggest new features
- Improve documentation

## License

This project is open source
