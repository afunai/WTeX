# encoding: UTF-8

# Author::    Akira FUNAI
# Copyright:: Copyright (c) 2011 Akira FUNAI

require "#{::File.dirname __FILE__}/t"

class TC_WikiTeX_Skip < Test::Unit::TestCase

  def setup
    @wt = WikiTeX.new
  end

  def teardown
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

  def test_tex_skip_command
    assert_equal(
      "foo \\bar baz\n",
      @wt.tex("foo \\bar baz"),
      'WikiTeX#tex should skip TeX commands beginning with backslash'
    )
    assert_equal(
      "foo \\bar baz \\qux\n",
      @wt.tex("foo \\bar baz \\qux"),
      'WikiTeX#tex should skip TeX commands beginning with backslash'
    )
    assert_equal(
      "foo \\bar baz \\qux\n",
      @wt.tex("foo \\bar baz \\qux\n"),
      'WikiTeX#tex should skip TeX commands beginning with backslash'
    )
    assert_equal(
      "foo \\bar baz \\qux \\$\n",
      @wt.tex("foo \\bar baz \\qux \\$\n"),
      'WikiTeX#tex should skip TeX commands beginning with backslash'
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

  def test_tex_skip_verb
    assert_equal(
      "\\verb|$%{|\n",
      @wt.tex('\verb|$%{|'),
      'WikiTeX#tex should skip inside verb commands'
    )
  end

  def test_tex_broken_verb
    assert_equal(
      "$\\backslash$verb\\textbar{}abc\n",
      @wt.tex('\verb|abc'),
      'WikiTeX#tex should escape broken verb commands'
    )
  end

  def test_tex_skip_curly_brackets
    assert_equal(
      "{$%#}\n",
      @wt.tex('{$%#}'),
      'WikiTeX#tex should skip inside curly brackets'
    )
  end

  def test_tex_skip_nested_curly_brackets
    [
      "{${%#}foo}\n",
      "{${%#}f{o}o}\n",
      "{{${%#}}f{o}o}\n",
      "{{${%#}f{o}o}}\n",
      "{${%#}f{o}o{}}\n",
      "{{}${%#}f{o}o}\n",
      <<'_eos',
foo {
  {$bar}
  {#baz{%qux}
}} foo
_eos
    ].each {|w|
      assert_equal(
        w,
        @wt.tex(w),
        'WikiTeX#tex should skip nested curly brackets'
      )
    }
  end

  def test_tex_escaped_curly_brackets
    [
      "{foo\\}$bar}\n",
      "{foo\\{$bar}\n",
      "{\\{foo$bar}\n",
      "{foo$bar\\}}\n",
      "{foo\\}$bar\\}$baz}\n",
      <<'_eos',
foo {
  {$bar}
  {#baz\{%qux
}} foo
_eos
    ].each {|w|
      assert_equal(
        w,
        @wt.tex(w),
        'WikiTeX#tex should be aware of escaped curly brackets'
      )
    }
  end

end
