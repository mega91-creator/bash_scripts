#!/bin/bash

# M-Pesa Plugin Export Script
# This script creates a clean export of the M-Pesa plugin for distribution

PLUGIN_NAME="mpesa-payment-gateway"
VERSION="1.0.0"
EXPORT_DIR="../${PLUGIN_NAME}-v${VERSION}"

echo "🚀 Exporting M-Pesa Payment Gateway Plugin v${VERSION}..."

# Create export directory
mkdir -p "$EXPORT_DIR"

# Copy plugin files (excluding development files)
echo "📁 Copying plugin files..."
rsync -av --exclude='.git' \
    --exclude='node_modules' \
    --exclude='vendor' \
    --exclude='*.log' \
    --exclude='.env*' \
    --exclude='composer.lock' \
    --exclude='package-lock.json' \
    --exclude='yarn.lock' \
    --exclude='.DS_Store' \
    --exclude='Thumbs.db' \
    --exclude='*.tmp' \
    --exclude='*.cache' \
    ./ "$EXPORT_DIR/"

# Create installation instructions
cat > "$EXPORT_DIR/INSTALLATION.md" << 'EOF'
# Installation Instructions

## Quick Install

1. **Extract the plugin** to your Laravel project's `platform/plugins/` directory
2. **Activate the plugin**:
   ```bash
   php artisan cms:plugin:activate mpesa
   ```
3. **Run migrations**:
   ```bash
   php artisan migrate
   ```
4. **Configure settings** in Admin Panel > Settings > Payment Methods > M-Pesa

## Manual Installation

If you prefer manual installation:

1. Copy the `mpesa` folder to `platform/plugins/mpesa`
2. Add to `composer.json`:
   ```json
   {
       "autoload": {
           "psr-4": {
               "Njovu\\Mpesa\\": "platform/plugins/mpesa/src/"
           }
       }
   }
   ```
3. Run `composer dump-autoload`
4. Activate and configure as above

## Requirements

- PHP >= 7.4
- Laravel >= 8.0
- Botble CMS >= 7.0.0
- Guzzle HTTP Client

## Support

For support, visit: https://github.com/philanjovu/mpesa-payment-gateway
EOF

# Create changelog
cat > "$EXPORT_DIR/CHANGELOG.md" << 'EOF'
# Changelog

All notable changes to the M-Pesa Payment Gateway Plugin will be documented in this file.

## [1.0.0] - 2025-01-27

### Added
- Complete M-Pesa STK Push integration
- Region-specific configuration support
- Comprehensive transaction tracking
- Admin interface integration
- Error handling and validation
- Phone number formatting
- Webhook callback support
- Security features (CSRF protection)
- Database migrations and models
- Console commands for cleanup

### Features
- Multi-region support for Kenyan counties
- Sandbox and live environment support
- Real-time payment status updates
- Detailed transaction logging
- User-friendly checkout experience
- Automatic payment status management

### Technical
- Laravel 8+ compatibility
- Botble CMS integration
- PSR-4 autoloading
- MIT license
- Comprehensive documentation
EOF

# Create license file
cat > "$EXPORT_DIR/LICENSE" << 'EOF'
MIT License

Copyright (c) 2025 Njovu Team

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
EOF

# Create package info
cat > "$EXPORT_DIR/package.json" << EOF
{
  "name": "${PLUGIN_NAME}",
  "version": "${VERSION}",
  "description": "Complete M-Pesa payment gateway integration for Laravel with comprehensive error handling, transaction tracking, and region-specific configurations",
  "keywords": ["mpesa", "payment", "gateway", "laravel", "botble", "safaricom", "kenya"],
  "author": "Njovu Team <info@njovu.com>",
  "license": "MIT",
  "repository": {
    "type": "git",
    "url": "https://github.com/philanjovu/mpesa-payment-gateway.git"
  },
  "bugs": {
    "url": "https://github.com/philanjovu/mpesa-payment-gateway/issues"
  },
  "homepage": "https://github.com/philanjovu/mpesa-payment-gateway#readme"
}
EOF

# Make the script executable
chmod +x "$EXPORT_DIR/export.sh"

echo "✅ Plugin exported successfully to: $EXPORT_DIR"
echo ""
echo "📦 Package contents:"
echo "   - Plugin source code"
echo "   - Documentation (README.md, INSTALLATION.md)"
echo "   - License (MIT)"
echo "   - Changelog"
echo "   - Package metadata"
echo ""
echo "🚀 Ready for distribution!"
echo ""
echo "To create a zip archive:"
echo "cd $EXPORT_DIR && zip -r ../${PLUGIN_NAME}-v${VERSION}.zip ." 