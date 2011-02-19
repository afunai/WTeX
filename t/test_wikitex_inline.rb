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

  def test_tex_escape_specials
    assert_equal(
      "\\\#{} \\%{} \\&{} \\_{}\n",
      @wt.tex('# % & _'),
      'WikiTeX#tex should escape all special characters in non-TeX paragraphs'
    )
    assert_equal(
      "\\textless{} \\textgreater{} \\textasciitilde{} \\textbar{} \\textasciicircum{}\n",
      @wt.tex('< > ^ | ~'),
      'WikiTeX#tex should escape all special characters in non-TeX paragraphs'
    )
  end

  def test_tex_skip_text_math_mode
    assert_equal(
      "$\\backslash$\n",
      @wt.tex('$\backslash$'),
      'WikiTeX#tex should skip inside TeX math modes'
    )
    assert_equal(
      "$\\backslash$ foo $\\backslash$ bar\n",
      @wt.tex('$\backslash$ foo $\backslash$ bar'),
      'WikiTeX#tex should skip inside TeX math modes'
    )

    assert_equal(
      "$big\\$dollar$\n",
      @wt.tex('$big\\$dollar$'),
      'WikiTeX#tex should be aware of escaped dollar marks inside TeX math modes'
    )
    assert_equal(
      "$big\\$dollar \\$wow$\n",
      @wt.tex('$big\\$dollar \\$wow$'),
      'WikiTeX#tex should be aware of escaped dollar marks inside TeX math modes'
    )

    w = <<'_eos'
foo$
  sqrt{x} + sqrt{y}
$ bar
_eos
    assert_equal(
      w,
      @wt.tex(w),
      'WikiTeX#tex should be aware of TeX math modes in multiple lines'
    )
  end

  def test_tex_broken_text_math_mode
    assert_equal(
      "\\${}foo\n",
      @wt.tex('$foo'),
      'WikiTeX#tex should escape broken TeX math modes'
    )
  end

end
