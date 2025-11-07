#!/bin/bash

# Fix the 4 remaining TODO comments with proper format
# Flutter expects: // TODO(username): Description
# Currently: // TODO(campus_mesh): ... (underscore not allowed)

set -e

echo "Fixing remaining TODO comments..."

# Replace TODO(campus_mesh): with TODO(dev):
sed -i 's/TODO(campus_mesh):/TODO(dev):/g' lib/services/mesh_network_service.dart
sed -i 's/TODO(campus_mesh):/TODO(dev):/g' lib/services/onesignal_service.dart  
sed -i 's/TODO(campus_mesh):/TODO(dev):/g' lib/services/security_service.dart

echo "✅ Fixed TODO comments"

# Fix duplicate ignores by cleaning up ignore_for_file lines
echo "Fixing duplicate ignores..."

# Fix profile_screen.dart - remove duplicate unreachable_switch_default
sed -i '1s/, unreachable_switch_default, unreachable_switch_default/, unreachable_switch_default/g' lib/screens/profile/profile_screen.dart

# Fix qr_scanner_screen.dart - remove duplicate dead_code and unreachable_switch_default
sed -i '1s/, dead_code, dead_code/, dead_code/g' lib/screens/qr/qr_scanner_screen.dart
sed -i '1s/, unreachable_switch_default, unreachable_switch_default/, unreachable_switch_default/g' lib/screens/qr/qr_scanner_screen.dart

# Fix app_logger_service.dart - keep just the file-level ignore
# Remove the inline ignore that's creating duplicate
head -1 lib/services/app_logger_service.dart | grep -q "ignore_for_file" && \
  sed -i '/^import.*platform.*/s|// ignore: avoid_slow_async_io||g' lib/services/app_logger_service.dart || true

echo "✅ Fixed duplicate ignores"

echo ""
echo "Running flutter analyze..."
flutter analyze 2>&1 | tail -5

