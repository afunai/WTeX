#!/usr/bin/env ruby
# encoding: UTF-8

# Author::    Akira FUNAI
# Copyright:: Copyright (c) 2011 Akira FUNAI

require 'test/unit'

t_dir = ::File.dirname __FILE__

$LOAD_PATH.unshift t_dir
$LOAD_PATH.unshift(::File.expand_path('../lib', t_dir))
require 'wikitex'
