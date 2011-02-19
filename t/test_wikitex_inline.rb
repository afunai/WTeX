# encoding: UTF-8

# Author::    Akira FUNAI
# Copyright:: Copyright (c) 2011 Akira FUNAI

require "#{::File.dirname __FILE__}/t"

class TC_WikiTeX_Inline < Test::Unit::TestCase

  def setup
    @wt = WikiTeX.new
  end

  def teardown
  end

  def test_tex_ruby_basic
    assert_equal(
      "これは\\ruby{漢字}{かんじ}です\n",
      @wt.tex('これは漢字《かんじ》です'),
      'WikiTeX#tex should deal with Japanese ruby characters'
    )
    assert_equal(
      "これは\\ruby{カタカナ}{かたかな}です\n",
      @wt.tex('これはカタカナ《かたかな》です'),
      'WikiTeX#tex should deal with Japanese ruby characters'

    )
    assert_equal(
      "これは\\ruby{コンピュータ}{電子計算機}です\n",
      @wt.tex('これはコンピュータ《電子計算機》です'),
      'WikiTeX#tex should deal with Japanese ruby characters'

    )
    assert_equal(
      "\\ruby{コンピュータ}{電子計算機}\n",
      @wt.tex('コンピュータ《電子計算機》'),
      'WikiTeX#tex should deal with Japanese ruby characters'
    )
  end

  def test_tex_ruby_border_implicit
    assert_equal(
      "でした。\\\\\n\\ruby{算盤}{そろばん}\n",
      @wt.tex("でした。\n算盤《そろばん》"),
      'WikiTeX#tex should detect boundaries of strings with/without rubies implicitly'
    )
    assert_equal(
      "はい、\\ruby{算盤}{そろばん}\n",
      @wt.tex('はい、算盤《そろばん》'),
      'WikiTeX#tex should detect boundaries of strings with/without rubies implicitly'
    )
    assert_equal(
      " \\ruby{算盤}{そろばん}\n",
      @wt.tex(' 算盤《そろばん》'),
      'WikiTeX#tex should detect boundaries of strings with/without rubies implicitly'
    )
    assert_equal(
      "　\\ruby{算盤}{そろばん}\n",
      @wt.tex('　算盤《そろばん》'),
      'WikiTeX#tex should detect boundaries of strings with/without rubies implicitly'
    )
    assert_equal(
      "「はい」\\ruby{算盤}{そろばん}\n",
      @wt.tex('「はい」算盤《そろばん》'),
      'WikiTeX#tex should detect boundaries of strings with/without rubies implicitly'
    )
    assert_equal(
      "ん？\\ruby{算盤}{そろばん}\n",
      @wt.tex('ん？算盤《そろばん》'),
      'WikiTeX#tex should detect boundaries of strings with/without rubies implicitly'
    )
    assert_equal(
      "♪\\ruby{算盤}{そろばん}\n",
      @wt.tex('♪算盤《そろばん》'),
      'WikiTeX#tex should detect boundaries of strings with/without rubies implicitly'
    )
    assert_equal(
      "…\\ruby{算盤}{そろばん}\n",
      @wt.tex('…算盤《そろばん》'),
      'WikiTeX#tex should detect boundaries of strings with/without rubies implicitly'
    )
  end

  def test_tex_ruby_border_explicit
    assert_equal(
      "大規模\\ruby{輻輳}{ふくそう}\n",
      @wt.tex('大規模｜輻輳《ふくそう》'),
      'WikiTeX#tex should detect boundaries of ruby characters by a pipe character'
    )
    assert_equal(
      "大規模\\ruby{輻輳}{ふくそう}\n",
      @wt.tex('大規模|輻輳《ふくそう》'),
      'WikiTeX#tex should detect boundaries of ruby characters by a pipe character'
    )
  end

  def test_tex_ruby_multiple
    assert_equal(
      "\\ruby{コンピュータ}{電子計算機}、\\ruby{算盤}{そろばん}\n",
      @wt.tex('コンピュータ《電子計算機》、算盤《そろばん》'),
      'WikiTeX#tex should deal with mutiple ruby commands'
    )
  end

  def test_tex_strong
    assert_equal(
      "{\\large\\bf foobar}\n",
      @wt.tex('**foobar**'),
      'WikiTeX#tex should deal with strong characters'
    )
    assert_equal(
      "{\\LARGE\\bf foobar}\n",
      @wt.tex('***foobar***'),
      'WikiTeX#tex should deal with strong characters'
    )
    assert_equal(
      "{\\Huge\\bf foobar}\n",
      @wt.tex('****foobar****'),
      'WikiTeX#tex should deal with strong characters'
    )

    assert_equal(
      "qux {\\large\\bf foobar} aaa\n",
      @wt.tex('qux **foobar** aaa'),
      'WikiTeX#tex should deal with strong characters'
    )
    assert_equal(
      "qux {\\Huge\\bf foobar} aaa\n",
      @wt.tex('qux ****foobar**** aaa'),
      'WikiTeX#tex should deal with strong characters'
    )
  end

  def test_tex_underline
    assert_equal(
      "\\WTunderline{foobar}\n",
      @wt.tex('__foobar__'),
      'WikiTeX#tex should deal with underlined characters'
    )

    assert_equal(
      "foo \\WTunderline{foobar} bar\n",
      @wt.tex('foo __foobar__ bar'),
      'WikiTeX#tex should deal with underlined characters'
    )
  end

end
