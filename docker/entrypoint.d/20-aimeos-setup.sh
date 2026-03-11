#!/bin/bash
set -e

echo "Publishing vendor assets..."
php artisan vendor:publish --all --force

echo "Running Aimeos setup..."
php artisan aimeos:setup
