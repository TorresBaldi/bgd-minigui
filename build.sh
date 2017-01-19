#!/bin/sh

# concatenate every prg file into one new prg
cat prg/gui-globals.prg prg/gui-functions.prg prg/gui-control-*.prg > minigui.prg

