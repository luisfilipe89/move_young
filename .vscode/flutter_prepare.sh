#!/bin/bash
echo "🔄 flutter clean"
flutter clean

echo "🔄 flutter pub get"
flutter pub get

echo "⏳ waiting a few seconds to ensure setup..."
sleep 3

echo "✅ flutter preparation done!"
