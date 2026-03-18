# Screenshot Organizer

An interactive terminal tool for reviewing and managing image files with inline image preview. Perfect for organizing screenshots, downloads, and quickly deleting unwanted images without leaving your terminal.

## Features

- **Inline Image Display**: View images directly in your terminal (WezTerm, iTerm2, and compatible terminals)
- **Interactive Management**: Delete, keep, or skip through images one by one
- **File Statistics**: Shows filename and file size for each image
- **Progress Tracking**: Displays current position in the image queue (e.g., `[3/10]`)
- **Batch Statistics**: Shows summary of deleted, kept, and unprocessed images
- **Early Exit**: Quit anytime with the `q` key and see partial results

## Requirements

- **Bash** 4.0+
- **Terminal with iTerm2 image protocol support**:
  - WezTerm (recommended)
  - iTerm2 (macOS)
  - Other modern terminals supporting the iTerm2 image protocol
- **Standard Unix tools**: `find`, `du`, `rm`, `base64`

## Installation

1. Clone or download this repository
2. Make the script executable:
   ```bash
   chmod +x so.sh
   ```
3. (Optional) Add to your PATH for global access:
   ```bash
   ln -s /path/to/so.sh /usr/local/bin/so
   # or
   cp so.sh /usr/local/bin/so
   ```

## Usage

### Basic Usage

Review images in the current directory:
```bash
./so.sh
```

Review images in a specific directory:
```bash
./so.sh ~/Downloads
./so.sh /path/to/images
```

### Interactive Controls

When an image is displayed, use the following keys:

| Key | Action |
|-----|--------|
| **y** or **Y** | Delete the current image |
| **n** or **N** | Keep the current image and move to next |
| **Enter** (or nothing) | Keep the current image and move to next |
| **q** or **Q** | Quit immediately and show summary |

### Example Session

```
📁 ~/Downloads に 5 件の画像が見つかりました
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[1/5] 📷 screenshot-001.png (2.3M)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[image displayed inline]

  [y] 削除  [n] 残す  [q] 終了 > y
  🗑️  削除しました: screenshot-001.png

[... continues with next image ...]

✨ 全て処理完了！
📊 結果: 削除 2件 / 残した 3件
```

## Supported Image Formats

The tool automatically detects and processes the following image formats:

- **PNG** (.png)
- **JPEG** (.jpg, .jpeg)
- **GIF** (.gif)
- **WebP** (.webp)

Format detection is case-insensitive.

## How It Works

1. **Discovers Images**: Finds all supported image files in the target directory (non-recursive)
2. **Converts to Base64**: Encodes the image file for terminal display
3. **Sends to Terminal**: Uses the iTerm2 image protocol to render the image inline
4. **Prompts User**: Waits for user input (delete, keep, or quit)
5. **Processes Action**: Deletes the file or moves to the next image
6. **Shows Summary**: Displays statistics after completion or early exit

### Image Display Protocol

The script uses the iTerm2 image protocol, which is supported by many modern terminals:

```bash
printf '\033]1337;File=inline=1;width=80%%;preserveAspectRatio=1:%s\a' "$(base64 < "$file")"
```

This sends the base64-encoded image to the terminal, which renders it at 80% terminal width while maintaining aspect ratio.

## Notes

### Terminal Compatibility

- **WezTerm**: Fully supported with excellent image rendering
- **iTerm2**: Fully supported (macOS)
- **VSCode Terminal**: Requires terminal profile configured for image protocol support
- **Traditional Bash/zsh**: May not render images; the script will still function for file management

### Safety

- **Deletion is permanent**: Deleted images are not moved to trash. The script uses direct file deletion (`rm`).
- **No undo**: There's no recovery option once an image is deleted
- **Recommended workflow**: Consider reviewing images in a test directory first or ensure backups exist

### Performance

- **Recommended for**: Directories with 10-100 images
- **Scalability**: The base64 encoding and inline display may be slow for very large image files (>10MB)
- **Directory structure**: Only processes images in the top level of the specified directory (non-recursive)

## Examples

### Organize Downloads folder
```bash
./so.sh ~/Downloads
```

### Clean up Screenshots directory (macOS)
```bash
./so.sh ~/Pictures/Screenshots
```

### Review images in current directory
```bash
cd /path/to/images
~/bin/so.sh
```

### Use as a global command (after installation)
```bash
so /Volumes/ExternalDrive/Photos
```

## Troubleshooting

### Images not displaying?

1. **Check terminal support**: Ensure your terminal supports the iTerm2 image protocol
2. **Test protocol**: Run this test command:
   ```bash
   printf '\033]1337;File=inline=1:%s\a' "$(base64 < /path/to/test.png)"
   ```
3. **Check image format**: Verify the image is a valid PNG, JPEG, GIF, or WebP file

### Script not executable?

```bash
chmod +x so.sh
```

### Command not found?

If you added the script to a custom location, ensure that location is in your PATH:
```bash
echo $PATH
```

## Contributing

Found a bug or have a feature suggestion? Please report it or submit a pull request.

## License

This script is provided as-is for personal and professional use.

## Related Tools

- **fzf**: Fuzzy file finder for interactive file selection
- **imagemagick**: Command-line image manipulation and conversion
- **exiftool**: Extract and modify image metadata
