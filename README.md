# iPhone Mirror

Control your iPhone from your Mac in a browser window: see the screen live, click to tap, drag to swipe, scroll, and type with your real keyboard. It's an open alternative to Apple's iPhone Mirroring, and it works in the EU.

## How it works

```
Browser UI  ──HTTP──>  mirror.mjs  ──usbmuxd (USB)──>  WebDriverAgent on the iPhone
   <img> MJPEG stream  <──────────────  screen frames (port 9100)
   clicks/drags/keys   ──────────────>  W3C touch actions + keyboard (port 8100)
```

- **WebDriverAgent** (Appium's open-source iOS automation agent) runs on the phone as an XCUITest runner. It streams the screen as MJPEG and accepts touch and keyboard input. That's the only no-jailbreak way to inject input into iOS.
- **mirror.mjs** talks to `usbmuxd` directly, the same daemon Finder and Xcode use, to tunnel to the phone over USB. You don't need libimobiledevice, iproxy or Appium. There are no npm dependencies either.
- Clicks become taps. Drags are replayed with the timing you used, so flicks fling and slow drags drag. Holding gives a long press. Wheel or trackpad scrolling becomes short, controlled swipes. Typing goes straight to the focused text field.

## Setup (once, about 10 minutes)

You need a Mac with **Xcode**, **Node 20+**, and a free Apple ID.

1. Open Xcode → Settings → Accounts and add your Apple ID. A free account is fine.
2. Plug in the iPhone, unlock it and tap **Trust**.
3. On the iPhone: Settings → Privacy & Security → **Developer Mode** → On (the phone restarts).
4. Run:
   ```bash
   git clone https://github.com/yachty66/iphone-mirror && cd iphone-mirror
   npm run setup        # downloads, signs and builds WebDriverAgent for your phone
   ```
   If your Team ID can't be detected, pass it in: `scripts/setup-wda.sh ABCDE12345`. It's shown in Xcode → Settings → Accounts.
5. The first time WDA launches, trust it on the iPhone: Settings → General → VPN & Device Management → your Apple ID → Trust.

## Use

```bash
npm start
```

This opens http://localhost:7100 and starts WebDriverAgent on the phone automatically.

| Input | Does |
| --- | --- |
| Click | Tap |
| Click and hold | Long press |
| Drag | Swipe or drag |
| Scroll wheel / trackpad | Scroll |
| Typing | Types into the focused field (Backspace, Enter and Tab work) |
| ⌘V | Types your Mac clipboard |
| ⌥H / ⌥J | Home / App Switcher |

The sidebar has Notifications, Control Center, Search, Lock/Wake, volume, Siri, an app launcher, and stream quality (20, 30 or 60 fps).

### Over WiFi

Once WDA is running, you can point the mirror at the phone's IP and unplug the cable. Xcode needs "Connect via network" enabled for the device so it can keep WDA running.

```bash
node mirror.mjs --wda http://192.168.1.23:8100
```

### Options

`--port 7100`, `--udid <udid>` (choose between several phones), `--wda-port`, `--mjpeg-port`, `--no-open`, `--no-autostart`, and `node mirror.mjs devices` to list connected phones.

## Limits compared to Apple's version

- The iPhone has to stay **unlocked with the screen on**. Set Auto-Lock to Never while mirroring. iOS only allows a locked, dark screen for Apple's private mirroring APIs.
- Video is MJPEG, not H.264, so expect roughly 100–200 ms latency.
- No audio forwarding, no notification mirroring, no drag-and-drop files.
- With a free Apple ID the WDA signature expires after **7 days**. Run `npm run setup` again to renew it.
- Some screens block automation input: the passcode screen, Apple Pay, and some banking apps.

## Development without an iPhone

`test/fake-iphone.mjs` fakes both usbmuxd and WebDriverAgent:

```bash
node test/fake-iphone.mjs                                   # terminal 1
USBMUXD_SOCKET_ADDRESS=/tmp/fake-usbmuxd.sock npm start     # terminal 2
npm test                                                    # end-to-end checks
```
