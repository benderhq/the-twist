# The Twist 🔀

![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/benderhq/the-twist/ci-workflow)

> [!IMPORTANT]
> The Twist, whose components are housed by this repository, is still in alpha/prototype stages. Expect frequent breaking changes (but also enthusiastic support) until the version number reaches 1.0.0

The Bender Twist is a free, portable platform which augments the functionality of the LT-series amps made by a guitar company that rhymes with "bender".

# Trailer

https://github.com/user-attachments/assets/ab2fa6d3-ed6a-48c6-a2fd-b2e2458a9679

## Quick Start

<table>
  <tr>
    <th colspan="2">Required Materials</th>
  </tr>
  <tr>
    <td colspan="1"><ul>
      <li>1x MicroSD Card (>8GB)</li>
            <li>1x Raspberry Pi Zero 2w</li>
            <li>1x MicroUSB -> MicroUSB Data Cable</li>
    </ul></td>
   <td colspan="1"><ul>
     <li>1x USB -> MicroUSB Power Cable</li>
            <li>1x MicroSD Card Reader (and/or 1x SD Card Adapter)</li>
            <li><i>Optional: 1x MiniHDMI -> HDMI Cable</i></li>
    </ul></td>
  </tr>
  <tr>
    <th> Instructions</th>
<th>Setup Diagram</th>
  </tr>
   <tr>
    <td><ol ><li>Go to <a href="/releases">Releases</a> and download a .img file which matches your target device (Raspberry Pi Zero 2w)</li></ol></td>
         <td rowspan="4"><picture><source media="(prefers-color-scheme: dark)" width="700px" srcset="https://github.com/user-attachments/assets/58ce5217-b79b-4d99-894d-8866c4a96b48"><source media="(prefers-color-scheme: light)" width="700px" srcset="[light-mode-image.png](https://github.com/user-attachments/assets/c4c7d9b0-8648-43ab-8645-886d6eda53cf)"><img alt="Fallback image description" width="700px" src="[default-image.png](https://github.com/user-attachments/assets/c4c7d9b0-8648-43ab-8645-886d6eda53cf)"></picture></td>

  </tr>
   <tr>
     <td><ol start="2"><li>Use a tool such as the Raspberry Pi Imager, Rufus, or `zstd` to flash the image file onto your microSD card.</li></ol></td>
  </tr>
     <tr>
     <td><ol start="3"><li>Unmount, eject, and unplug microSD before inserting it into target device.</li></ol></td>
  </tr>
     <tr>
     <td><ol start="4"><li>Supply power to target device.</li></ol></td>
  </tr>
</table>

### Usage

- Connect to local WAP (wireless access point)
  - Default AP credentials:
    - SSID: the-twist
    - Password: bendernotfender
  - Access Network Management Captive Portal
    - Toggle/Configure Wifi or AP modes/credentials
    - Automatically reconfigures control panel as default portal
  - Redirect to mobile-friendly Control Panel Interface with:
    - Amp connection manager with:
      - Soon: Support for all models
    - Amp stat viewing (memory, CPU usage) with:
      - Soon: Dynamic graphs
    - Amp preset remote control
      - Footswitch playlist management
    - Light/dark mode color themes

## The Layout

This repository contains almost everything related to The Twist, as well asthe  various add-ons that may be developed in the future.

```bash
~/the-twist
├── .github # automated builds & CI
├── 3d # 3d-print files for thetwist's case options (soon)
├── addons # battery support, speaker, screens (soon)
├── backend # api server controlling amp connectivity
│   ├── ltamp # vendored ltamp.py package
│   ├── app.py # fastapi entry point
│   └── default.nix 
├── docs # documentation markdown
├── frontend # svelte control panel interface
│   ├── public # assets
│   ├── src
│   │   ├── components # reusable ui parts
│   │   ├── lib # utils and lil things
│   │   ├── pages # SPA routes
│   │   └── stores # event/state management
│   └── default.nix 
├── portal # wifi/WAP configuration server
├── site # marketing website
├── flake.nix
└── flake.lock
```
## Development

To start the backend manually, run:

```bash
cd backend
uvicorn app:app --host 0.0.0.0 --port 80 --reload
```

To build new changes to the Svelte frontend, run. Unfortunately, due to no amp simulator being built for LtAmp.py (that maintainer should really get on that!!), you may have to build every time you make changes. Sorry :(

```bash
cd frontend
npm run build

To build the SD installer file, please run the following:

```
nix build \
  --system aarch64-linux \
  --max-jobs 0 \
  --builders "ssh://eu.nixbuild.net aarch64-linux - 100 1 big-parallel,benchmark" \
  .#installerImages.rpi02

sudo dd if=/dev/zero of=/dev/sda bs=8192

zstd -dc result/sd-image/nixos-image-rpi02-uboot.img.zst | sudo dd of=/dev/sda bs=4M conv=fsync status=progress

sudo umount /dev/sda*; sudo eject /dev/sda
```

Default SSH Credentials

- Hostname: twist.local
- Password: bendernotfender

## Roadmap

Planned features, known bugs, and the overall project roadmap are coorinated using a combination of GitHub's Issues and Projects. The project [tab](https://github.com/bendertools/projects) is where more broad, long-term, and important work is tracked, while day-to-day development progress is reserved for Issues and Pull Requests.



