<p align="right"><a href="README.pt-BR.md">🇧🇷 Português</a></p>

# FFmpeg Audio Converter Toolkit
Scripts and comprehensive guide for converting FLAC to MP3 with FFmpeg, including safe conversion, integrity validation, and metadata tagging with MusicBrainz Picard.

**Last updated:** October 01, 2026

This guide provides step-by-step instructions for converting audio files, with special focus on transitioning from FLAC to MP3 while preserving maximum quality and metadata.

Official FFmpeg documentation: [https://ffmpeg.org/ffmpeg.html](https://ffmpeg.org/ffmpeg.html).

This guide also includes a brief section on [MusicBrainz Picard](https://picard.musicbrainz.org/), which I use to obtain complete metadata for music and albums from a database of officially released discs with data from various album releases.

Another alternative for converting audio files is the software [Foobar2000](https://www.foobar2000.org/), which has a graphical interface and is one of the oldest and most complete media players on the internet.

---

## 1. Installing FFmpeg

The easiest way to install is through Windows Package Manager (winget), since the official site (https://ffmpeg.org/) only provides binaries, and you would have to configure the PATH manually.

Open PowerShell:
```powershell
winget install ffmpeg
```

After installation, if the terminal doesn't recognize ffmpeg, update the PATH manually:

```powershell
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
```

---

## Convert Entire Folder of FLAC to MP3

### V0 Quality (Variable - High Quality - recommended)
```powershell
Get-ChildItem -Filter "*.flac" | ForEach-Object {
    ffmpeg -i $_.FullName -q:a 0 -map_metadata 0 "$($_.DirectoryName)\$($_.BaseName).mp3"
}
```

### 320 kbps (maximum MP3 quality)
```powershell
Get-ChildItem -Filter "*.flac" | ForEach-Object {
    ffmpeg -i $_.FullName -b:a 320k -map_metadata 0 "$($_.DirectoryName)\$($_.BaseName).mp3"
}
```

### 256 kbps or other formats
```powershell
Get-ChildItem -Filter "*.flac" | ForEach-Object {
    ffmpeg -i $_.FullName -b:a 256k -map_metadata 0 "$($_.DirectoryName)\$($_.BaseName).mp3"
}
```

### Conversion with Verification and Logging (Safe for deleting FLAC)
For those who want to automate integrity checking and have a final report before deleting originals, the ideal is to use a PowerShell script with `.ps1` extension.

Example of basic logic to run in the terminal:
```powershell
# Simplified example to run in terminal (generates basic log)
$sucessos = 0; $erros = 0
Get-ChildItem -Filter "*.flac" | ForEach-Object {
    $out = "$($_.DirectoryName)\$($_.BaseName).mp3"
    ffmpeg -i $_.FullName -q:a 0 -map_metadata 0 $out 2>$null
    if ($LASTEXITCODE -eq 0) { $sucessos++ } else { $erros++ }
}
Write-Host "Converted: $sucessos | Failures: $erros"
```

> Navigate to the FLAC folder before running: `cd "C:\path\to\folder"`

---

## Summary of Main FFmpeg Commands

### Basic conversion
```powershell
ffmpeg -i input.flac output.mp3
```

### Conversion with specific bitrate
```powershell
ffmpeg -i input.flac -b:a 256k output.mp3
```

### Conversion preserving metadata (tags, cover)
```powershell
ffmpeg -i input.flac -b:a 256k -map_metadata 0 output.mp3
```

### Convert to other formats
```powershell
ffmpeg -i input.flac output.ogg
ffmpeg -i input.mp3 output.wav
ffmpeg -i input.flac output.aac
```

### View audio file information
```powershell
ffmpeg -i file.flac
```

### Trim audio (from 00:01:00 to 00:03:30)
```powershell
ffmpeg -i input.mp3 -ss 00:01:00 -to 00:03:30 output.mp3
```

### Trim audio by duration (starts at second 60, lasts 90 seconds)
```powershell
ffmpeg -i input.mp3 -ss 60 -t 90 output.mp3
```

### Normalize volume
```powershell
ffmpeg -i input.mp3 -filter:a loudnorm output.mp3
```

### Extract audio from video
```powershell
ffmpeg -i video.mp4 -vn -b:a 256k audio.mp3
```

### Convert multiple files in batch (entire folder)
```powershell
Get-ChildItem -Filter "*.flac" | ForEach-Object {
    ffmpeg -i $_.FullName -q:a 0 -map_metadata 0 "$($_.DirectoryName)\$($_.BaseName).mp3"
}
```

### Convert specific folder
```powershell
Get-ChildItem -Path "C:\path\to\folder" -Filter "*.flac" | ForEach-Object {
    ffmpeg -i $_.FullName -q:a 0 -map_metadata 0 "$($_.DirectoryName)\$($_.BaseName).mp3"
}
```

---

## MP3 Quality Table

| kbps / Type | Quality |
|------|-----------|
| V0 | Maximum (Variable), the best fidelity/size ratio |
| 320  | Maximum (Constant), indistinguishable from FLAC for most |
| 256  | Very good, smaller file |
| 192  | Good, balanced size |
| 128  | Acceptable, small files |

---

## Creating and Executing Scripts (.ps1)

When commands become very long or require complex checks (like comparing MP3 duration with FLAC), the best practice is to create a PowerShell script.

### 1. How to create the script
1. Open VS Code.
2. Choose one of the models below (according to your needs) and create the file with the `.ps1` extension.
3. **Important**: Open the file and edit the `$root = 'D:\Music'` variable to your music folder path.

#### Available Models

The scripts are located in the `/scripts` folder of this repository. You can download them or copy the content and paste into any text editor, saving with the `.ps1` extension.

- **`QuickConvert.ps1`**: Direct and fast conversion. Ideal for those who trust files completely.
- **`SafeConvert.ps1`**: Uses temporary files (`.tmp`). Only renames to `.mp3` if conversion completes without errors.
- **`AuditConvert.ps1`**: Maximum security level. Inventories file size, uses `ffprobe` to validate that the MP3 audio is real and functional before giving the OK.

**Usage Tip**: You can place the script inside your music folder. If you want this, change the line: `$root = 'D:\Music'` to:
```powershell
$root = $PSScriptRoot
```
This way, the script will automatically convert all FLACs in the folder where it's located and in all subfolders.

> Scripts are configured with the `-q:a 0` argument, which converts at maximum quality with variable bitrate.

### 2. How to execute the script

By default, Windows blocks script execution for security. To run your script:

**Option A: Execute via VS Code Terminal**
```powershell
.\AuditConvert.ps1
```

*If you get an "Execution Policy" error, before running the script, execute:*
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```
And confirm to allow the current user to run PowerShell scripts.

**Option B: Execute via PowerShell (Admin)**
1. Open PowerShell as Administrator.
2. Navigate to the folder: `cd "C:\path\to\script"`
3. Execute: `.\AuditConvert.ps1`

---

## Advanced Security and Validation Techniques

For those who want professional-level precision (server-style), there are three techniques that ensure no files are lost or corrupted:

### 1. Conversion via Temporary File (`.tmp`)
Instead of converting directly to `.mp3`, the script converts to `.mp3.tmp`. 
- **Why?** If conversion fails midway, you'll have an incomplete `.tmp` file, but won't have a "fake" `.mp3` file that would fool the system.
- **Flow**: `FLAC` → `MP3.tmp` → (Validation OK?) → `MP3`

### 2. Prior Conflict Detection
Before starting, you can run an inventory to map which FLACs already have a corresponding MP3. This avoids unnecessary processing and allows creating a list of "files to ignore".

### 3. Technical Validation with `ffprobe`
The `ffprobe` (ffmpeg's sibling) can read the file's "anatomy". To ensure the MP3 is valid, we can check:
- **Codec**: Confirm it's `mp3`.
- **Duration**: Verify duration is greater than zero.
- **Bitrate**: Validate bitrate is within expected range (e.g., between 300kbps and 330kbps for 320k MP3).

---

## Metadata Editing and Lookup (MusicBrainz Picard)

To organize your library after conversion, **MusicBrainz Picard** is the recommended tool for fetching accurate metadata and automatically renaming files.

You can download it from the official site: [https://picard.musicbrainz.org/](https://picard.musicbrainz.org/)

### File Naming Script Configuration
To avoid name collisions in multi-disc albums and keep organization clean, you can configure the **File naming script editor** with the following command:

```text
$if2(%albumartist%,%artist%)-$if($gt(%totaldiscs%,1),%discnumber%-)$num(%tracknumber%,2)-%title%
```

### What this does:
- **Multi-disc albums** (`%totaldiscs%` > 1): Adds the disc number before the track.
  - *Result:* `Eisbrecher-1-01-Eisbär.mp3`, `Eisbrecher-2-01-Schwarze Witwe (2018).mp3`
- **Single-disc albums**: Keeps the simple format, without adding disc number.
  - *Result:* `Eisbrecher-01-Polarstern.mp3`

**How to apply:** Paste the script in Picard's rename editor and click **"Apply"** to apply changes to selected files.

---

## Using Foobar2000

As an alternative to FFmpeg (which has no graphical interface and can be a barrier for command-line novices), you can use Foobar2000, downloadable from [https://www.foobar2000.org/](https://www.foobar2000.org/).

**foobar2000** is widely considered one of the best audio converters for Windows, being very practical for converting batches of FLAC to MP3 (whether V0 or 320 kbps) without touching command lines.

Since foobar2000 needs the official LAME MP3 encoder executable to perform conversions with advanced profiles (like V0), the process involves quick initial setup and then a very simple conversion routine.

### Step 1: Initial Setup (Download LAME Converter)

Foobar2000 by itself doesn't natively convert to MP3 without the official LAME file due to patent issues.

1. Download the official **Encoder Pack** from the foobar2000 site (`foobar2000.org` in the components section) or download the `lame.exe` file directly.

2. Extract `lame.exe` to an easily accessible folder on your computer (for example, `C:\Tools\lame.exe`).

### Step 2: Creating Your Routine (Step-by-step Guide) in foobar2000

Once configured, to convert your FLACs in batch, follow this workflow:

#### 1. Import files

- Open **foobar2000**.
- Drag the folder or `.flac` files you want to convert directly into the program's main window.

#### 2. Select and trigger conversion

- Select all songs in the list (press `Ctrl + A`).
- Right-click on the selected songs.
- Go to **Convert** > **... (Quick Convert)** or **Convert** > **Convert**.

#### 3. Configure Output Profile (MP3 V0 or 320 kbps)

In the configuration window that opens, choose the output format:

- Click **Output format**.
- Select **MP3 (lame)**.
- Adjust the quality mode according to your preference:
  - **For V0 quality (VBR):** Choose _VBR_ mode and move the slider to maximum quality (equivalent to V0 preset, usually generating dynamic rates around 245 kbps).
  - **For 320 kbps (CBR):** Choose _CBR_ mode and set the fixed value to **320 kbps**.
- Click **Back**.

#### 4. Specify where LAME is (Only first time)

- If foobar2000 asks where the **`lame.exe`** file is located, navigate to the folder where you saved it in Step 1 (`C:\Tools\lame.exe`) and select it. The program remembers this path forever.

#### 5. Set destination and convert

- In **Destination**, choose whether to save MP3s in the same folder as the original files or in a separate folder.
- Click the **Convert** button.

### How to Create Presets

To create **presets** in foobar2000 — allowing you to switch with one click between the **MP3 V0** and **MP3 320 kbps** profiles without reconfiguring everything again —, you use the **Converter Setup** tool.

Follow this step-by-step workflow:

#### Step 1: Open the Converter and Configure the First Preset (e.g., MP3 V0)

1. In foobar2000, select some songs in the list, right-click and go to **Convert** > **... (Quick Convert)** (or _Convert_).

2. In the window that opens, click **Output format**, select **MP3 (lame)** and configure the parameters for **V0** (VBR mode at maximum quality).

3. Also adjust other options you want saved in this profile (for example: file naming pattern in _Destination_ or cover art handling).

4. At the top of that configuration window, look for the **Save** or **Save preset** button.

5. Give it a clear name, such as: **`MP3 - V0 VBR`** and save.

#### Step 2: Create the Second Preset (e.g., MP3 320 kbps)

1. Still in the same window, change the output format (**Output format**) to **MP3 (lame)**, but now configure the mode to **CBR** and set the fixed value to **320 kbps**.

2. Go back to the top of the window and click **Save** / **Save preset** again.

3. Give it a name to differentiate, such as: **`MP3 - 320kbps CBR`** and save.

#### How to use your Presets from now on:

With presets saved, you'll never need to reconfigure audio options again:

1. Select the FLAC files you want to convert.

2. Right-click and go to **Convert** > **Convert (full menu)** or the shortcut that leads directly to your saved presets.

3. You'll see a list with your created profiles (**`MP3 - V0 VBR`** and **`MP3 - 320kbps CBR`**).

4. Just click on the desired preset and conversion will start instantly with ready-made settings!

### Advantages of foobar2000 over FFmpeg scripts:

- **Metadata and Covers:** It automatically copies album covers (`cover.jpg` or embedded tags) directly to generated MP3 files without needing extra mapping commands.

- **Graphical Interface:** Allows you to visualize the progress of converting multiple files in parallel in a very clean way.
