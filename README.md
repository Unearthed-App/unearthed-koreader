# Unearthed KOReader Plugin for Obsidian Syncing

Seamlessly sync your KOReader highlights and notes to Obsidian via Unearthed.app (Unearthed Online) or via [Unearthed Local](https://unearthed.app/local) (local app). This plugin is a simple one, it's just here to get those highlights and notes off your device and sync them to places that you might want them. So that they aren't locked and lost on whatever device you're using. So that you can combine them with highlights and notes from other sources too. Unearthed can also sync Kindle highlights automatically and merge them with your KOReader highlights. This plugin enables you to maintain an organised collection of your reading insights in one place. This is accomplished by using Unearthed (online or local version) as a middle man. Most of the software is open source, so please inspect the code or even run it yourself if you like.

> _After the setup is complete, you will **not** need to physically plug in your KOReader device to perform a sync!_ ( ͡° ͜ʖ ͡°)

#### There are 2 ways to sync using Unearthed. *[Unearthed Local](https://unearthed.app/local) (one time payment)*, and *Unearthed Online (ongoing subscription)*

**Note:** *Unearthed Online* can also facilitate syncing to places beyond Obsidian. You can also just sync to [Unearthed.app](https://unearthed.app) or the Local app and digest the knowledge there if you like.

So far, only tested with:

- KOReader version: 2025.04
- On a Boox Palma

## Features (on unearthed.app - *Unearthed Online*)
#### Probably easier to just look at unearthed.app but here are **some**...
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

- *Unearthed Local* (one time purchase) app installed, OR a paid Unearthed.app account
- KOReader installed on your device
- Obsidian connected to Unearthed. Follow the instructions here: [Unearthed Obsidian Github](https://github.com/Unearthed-App/unearthed-obsidian)

## Installation for *Unearthed Local*

1. Download *[Unearthed Local](https://unearthed.app/local)* from [unearthed.app](https://unearthed.app) and install it on your computer
2. Go to [Releases](https://github.com/Unearthed-App/unearthed-koreader/releases) and download the zip file for latest release
3. Connect your device via USB and navigate to `koreader/plugins` folder
4. Unzip the file into `koreader/plugins` folder, making sure that the parent folder still remains (e.g., `koreader/plugins/Unearthed.koplugin`)
5. On your device, restart KOReader and then go to tools and see if 'Unearthed' is listed as a menu item. If it is not listed there, go to `Tools → MoreTools → Plugin Management` and make sure 'Unearthed' is enabled
6. Open `Tools → Unearthed → General Settings` and keep it open. Select `Book Location` and input the path to the folder that holds your books along with your books' metadata. This must be the absolute path. You can find it by navigating your device's file system from within the KOReader app. Then look at the top of the app under the word KOReader to see the actual path. Here's an example for an Android device `/storage/emulated/0/Books`
7. Ensure your E-reader and computer are on the same network.
8. Open the *[Unearthed Local](https://unearthed.app/local)* app on your computer and go to Settings. Create a secret under **API Endpoint** (type anything you like) - **Don't forget to press save**. Type the same secret into the KORreader plugin settings under `Tools → Unearthed → Local Settings → Secret`
9. Open the *[Unearthed Local](https://unearthed.app/local)* app on your computer and copy the *API Endpoint* into the KOReader plugin on your E-reader, under `Tools → Unearthed → Local Settings → Local URL`
10. Exit settings, and go back into `Tools → Unearthed → Send Books` and then wait
11. Wait until a confirmation message appears. This may take a while if you have many books. Open the *[Unearthed Local](https://unearthed.app/local)* app on your computer scroll down to the **Database** section to see if the books have arrived. You may need to refresh the data within the app.


## Installation for *Unearthed Online*

1. Create a paid account on [unearthed.app](https://unearthed.app)
2. Go to [Releases](https://github.com/Unearthed-App/unearthed-koreader/releases) and download the zip file for latest release
3. Connect your device via USB and navigate to `koreader/plugins` folder
4. Unzip the file into `koreader/plugins` folder, making sure that the parent folder still remains (e.g., `koreader/plugins/Unearthed.koplugin`)
5. On your device, restart KOReader and then go to tools and see if 'Unearthed' is listed as a menu item. If it is not listed there, go to `Tools → MoreTools → Plugin Management` and make sure 'Unearthed' is enabled
6. Open `Tools → Unearthed → General Settings` and keep it open. Select `Book Location` and input the path to the folder that holds your books along with your books' metadata. This must be the absolute path. You can find it by navigating your device's file system from within the KOReader app. Then look at the top of the app under the word KOReader to see the actual path. Here's an example for an Android device `/storage/emulated/0/Books`
7. Login to Unearthed.app, go to settings and create an API Key, name it whatever you like. Copy it immediately and paste it into **API Key** in the KOReader Unearthed plugin settings, under `Tools → Unearthed → Online Settings`
8.  Login to Unearthed.app, go to settings (general) and press the copy button next to 'User ID' and paste it into `User ID` in the KOReader Unearthed plugin settings, under `Tools → Unearthed → Online Settings`
9.  Exit settings, and go back into `Tools → Unearthed → Send Books` and then wait
10. Wait until a confirmation message appears. This may take a while if you have many books. Go to Unearthed.app books page and confirm that Unearthed received your books and highlights
11. After you have your KOReader syncing to Unearthed.app, Follow the instructions here to send that data to Obsidian: [Unearthed Obsidian Github](https://github.com/Unearthed-App/unearthed-obsidian)


## Settings
- **Book Location**: The folder that holds your books along with your books' metadata. Only one location is supported at this time
- **API Key**: A unique Unearthed API key for authentication
- **User ID**: Your unique User ID
- **Auto-sync**: Enable/disable automatic syncing of highlights. When enabled, the plugin will send your highlights to Unearthed.app when you first open KOReader, once per day

## Settings
### General

* **Book Location**: The folder that holds your books and their metadata (.sdr directories). Only one location is supported.

---

### Online (Unearthed.app)

* **API Key**: Your Unearthed Online API key for authenticating uploads.
* **User ID**: Your Unearthed Online user ID (used together with the API key).
* **Auto sync on startup**: Enable/disable a daily sync with Unearthed Online when KOReader is opened.
* **Auto sync hourly**: Enable/disable hourly sync with Unearthed Online while KOReader is running.

---

### Local ([Unearthed Local](https://unearthed.app/local))

* **Local URL**: URL of your Unearthed Local instance (e.g. `http://192.168.x.x:port`). Re-check if your computer IP changes.
* **Local Secret**: Shared secret used to authenticate with Unearthed Local.
* **Auto sync on startup (Local)**: Enable/disable a daily sync with Unearthed Local when KOReader is opened.
* **Auto sync hourly (Local)**: Enable/disable hourly sync with Unearthed Local while KOReader is running.



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
3. Ensure you have an active **Unearthed Online** account, OR have **[Unearthed Local](https://unearthed.app/local)** installed
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
