# encoding: UTF-8

# Author::    Akira FUNAI
# Copyright:: Copyright (c) 2011 Akira FUNAI

require "#{::File.dirname __FILE__}/t"
require 'fileutils'

class TC_WikiTeX_Bin < Test::Unit::TestCase

  def setup
    @tmp_dir = ::File.expand_path('./tmp', ::File.dirname(__FILE__))
    ::FileUtils.rm_r ::Dir.glob("#{@tmp_dir}/*")
  end

  def teardown
  end

  def test_init
    ::Dir.chdir(@tmp_dir) do
      system('../../bin/wikitex init foobar 2>/dev/null')
      assert(
        ::File.exists?('./foobar'),
        'wikitex command should copy skeltons to the target directory'
      )
    end
  end

end
