#!/usr/bin/env sh

set -ex

mv ~/.ipython/profile_default/startup/ ~/.ipython/profile_default/startup.bak
ln -s ~/dotfiles/.ipython/startup ~/.ipython/profile_default/startup
