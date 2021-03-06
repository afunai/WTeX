# encoding: UTF-8

# Author::    Akira FUNAI
# Copyright:: Copyright (c) 2011 Akira FUNAI

require "#{::File.dirname __FILE__}/t"

class TC_WTeX_Inline < Test::Unit::TestCase

  def setup
    @wt = WTeX.new
  end

  def teardown
  end

  def test_tex_ruby_basic
    assert_equal(
      "これは\\ruby{漢字}{かんじ}です\n",
      @wt.tex('これは漢字《かんじ》です'),
      'WTeX#tex should deal with Japanese ruby characters'
    )
    assert_equal(
      "これは\\ruby{カタカナ}{かたかな}です\n",
      @wt.tex('これはカタカナ《かたかな》です'),
      'WTeX#tex should deal with Japanese ruby characters'

    )
    assert_equal(
      "これは\\ruby{コンピュータ}{電子計算機}です\n",
      @wt.tex('これはコンピュータ《電子計算機》です'),
      'WTeX#tex should deal with Japanese ruby characters'

    )
    assert_equal(
      "\\ruby{コンピュータ}{電子計算機}\n",
      @wt.tex('コンピュータ《電子計算機》'),
      'WTeX#tex should deal with Japanese ruby characters'
    )
  end

  def test_tex_ruby_border_implicit
    assert_equal(
      "でした。\\\\\n\\ruby{算盤}{そろばん}\n",
      @wt.tex("でした。\n算盤《そろばん》"),
      'WTeX#tex should detect boundaries of strings with/without rubies implicitly'
    )
    assert_equal(
      "はい、\\ruby{算盤}{そろばん}\n",
      @wt.tex('はい、算盤《そろばん》'),
      'WTeX#tex should detect boundaries of strings with/without rubies implicitly'
    )
    assert_equal(
      " \\ruby{算盤}{そろばん}\n",
      @wt.tex(' 算盤《そろばん》'),
      'WTeX#tex should detect boundaries of strings with/without rubies implicitly'
    )
    assert_equal(
      "　\\ruby{算盤}{そろばん}\n",
      @wt.tex('　算盤《そろばん》'),
      'WTeX#tex should detect boundaries of strings with/without rubies implicitly'
    )
    assert_equal(
      "「はい」\\ruby{算盤}{そろばん}\n",
      @wt.tex('「はい」算盤《そろばん》'),
      'WTeX#tex should detect boundaries of strings with/without rubies implicitly'
    )
    assert_equal(
      "ん？\\ruby{算盤}{そろばん}\n",
      @wt.tex('ん？算盤《そろばん》'),
      'WTeX#tex should detect boundaries of strings with/without rubies implicitly'
    )
    assert_equal(
      "♪\\ruby{算盤}{そろばん}\n",
      @wt.tex('♪算盤《そろばん》'),
      'WTeX#tex should detect boundaries of strings with/without rubies implicitly'
    )
    assert_equal(
      "…\\ruby{算盤}{そろばん}\n",
      @wt.tex('…算盤《そろばん》'),
      'WTeX#tex should detect boundaries of strings with/without rubies implicitly'
    )
  end

  def test_tex_ruby_border_explicit
    assert_equal(
      "大規模\\ruby{輻輳}{ふくそう}\n",
      @wt.tex('大規模｜輻輳《ふくそう》'),
      'WTeX#tex should detect boundaries of ruby characters by a pipe character'
    )
    assert_equal(
      "大規模\\ruby{輻輳}{ふくそう}\n",
      @wt.tex('大規模|輻輳《ふくそう》'),
      'WTeX#tex should detect boundaries of ruby characters by a pipe character'
    )
  end

  def test_tex_ruby_multiple
    assert_equal(
      "\\ruby{コンピュータ}{電子計算機}、\\ruby{算盤}{そろばん}\n",
      @wt.tex('コンピュータ《電子計算機》、算盤《そろばん》'),
      'WTeX#tex should deal with mutiple ruby commands'
    )
  end

  def test_tex_strong
    assert_equal(
      "{\\large\\bf foobar}\n",
      @wt.tex('**foobar**'),
      'WTeX#tex should deal with strong characters'
    )
    assert_equal(
      "{\\LARGE\\bf foobar}\n",
      @wt.tex('***foobar***'),
      'WTeX#tex should deal with strong characters'
    )
    assert_equal(
      "{\\Huge\\bf foobar}\n",
      @wt.tex('****foobar****'),
      'WTeX#tex should deal with strong characters'
    )

    assert_equal(
      "qux {\\large\\bf foobar} aaa\n",
      @wt.tex('qux **foobar** aaa'),
      'WTeX#tex should deal with strong characters'
    )
    assert_equal(
      "qux {\\Huge\\bf foobar} aaa\n",
      @wt.tex('qux ****foobar**** aaa'),
      'WTeX#tex should deal with strong characters'
    )
  end

  def test_tex_underline
    assert_equal(
      "\\WTunderline{foobar}\n",
      @wt.tex('__foobar__'),
      'WTeX#tex should deal with underlined characters'
    )

    assert_equal(
      "foo \\WTunderline{foobar} bar\n",
      @wt.tex('foo __foobar__ bar'),
      'WTeX#tex should deal with underlined characters'
    )
  end

  def test_tex_combined_basic
    assert_equal(
      "foo\\WTcombined{!!}\n",
      @wt.tex('foo!!'),
      "WTeX#tex should combine multiple '!' characters"
    )
    assert_equal(
      "foo\\WTcombined{!!}\n",
      @wt.tex('foo！！'),
      "WTeX#tex should combine multiple '!' characters"
    )

    assert_equal(
      "foo\\WTcombined{?!}\n",
      @wt.tex('foo?!'),
      "WTeX#tex should combine '?' and '!'"
    )
    assert_equal(
      "foo\\WTcombined{?!}\n",
      @wt.tex('foo？！'),
      "WTeX#tex should combine '?' and '!'"
    )

    assert_equal(
      "foo\\WTcombined{?!}bar\\WTcombined{!!}\n",
      @wt.tex('foo？！bar!!'),
      "WTeX#tex should combine '?' and '!'"
    )
  end

  def test_tex_combined_irregular
    assert_equal(
      "foo!\n",
      @wt.tex('foo!'),
      "WTeX#tex should leave single '!' character"
    )
    assert_equal(
      "foo！\n",
      @wt.tex('foo！'),
      "WTeX#tex should leave single '!' character"
    )
    assert_equal(
      "foo?\n",
      @wt.tex('foo?'),
      "WTeX#tex should leave single '?' character"
    )
    assert_equal(
      "foo？\n",
      @wt.tex('foo？'),
      "WTeX#tex should leave single '?' character"
    )

    assert_equal(
      "foo\\WTcombined{!!!}\n",
      @wt.tex('foo！！！'),
      'WTeX#tex should deal with more than two characters'
    )
    assert_equal(
      "foo\\WTcombined{?!!}\n",
      @wt.tex('foo？！！'),
      'WTeX#tex should deal with more than two characters'
    )
  end

end
