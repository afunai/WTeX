# encoding: UTF-8

# Author::    Akira FUNAI
# Copyright:: Copyright (c) 2011 Akira FUNAI

require "#{::File.dirname __FILE__}/t"
require 'fileutils'

class TC_WTeX_Bin < Test::Unit::TestCase

  def setup
    @tmp_dir = ::File.expand_path('./tmp', ::File.dirname(__FILE__))
    ::FileUtils.rm_r ::Dir.glob("#{@tmp_dir}/*")
  end

  def teardown
  end

  def test_bin
    ::Dir.chdir(@tmp_dir) do
      system('../../bin/wikitex init foobar 2>/dev/null')
      assert(
        ::File.exists?('./foobar'),
        "'init' command should copy skeltons to the target directory"
      )

      ::Dir.chdir('./foobar') do
        system('../../../bin/wikitex convert')
        assert(
          ::File.size?('./body.tex'),
          "'convert' command should convert body.txt into out/body.tex"
        )
      end
    end
  end

end
