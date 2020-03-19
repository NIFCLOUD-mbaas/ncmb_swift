#!/bin/sh
swiftfile=$(mktemp)
cat NCMB/NCMB.swift > $swiftfile
echo '' >> $swiftfile
echo 'print(NCMB.SDK_VERSION)' >> $swiftfile
sdk_version=$(swift $swiftfile)
echo $sdk_version

jazzy \
  --clean \
  -- swift-version 4.2 \
  --author fjct \
  --author_url https://mbaas.nifcloud.com/ \
  --module-version $sdk_version \
  --module NCMB \
  --min-acl public

rm -f $swiftfile
