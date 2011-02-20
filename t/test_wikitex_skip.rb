# encoding: UTF-8

# Author::    Akira FUNAI
# Copyright:: Copyright (c) 2011 Akira FUNAI

require "#{::File.dirname __FILE__}/t"

class TC_WTeX_Skip < Test::Unit::TestCase

  def setup
    @wt = WTeX.new
  end

  def teardown
  end

  def test_tex_escape_specials
    assert_equal(
      "\\\#{} \\%{} \\&{} \\_{}\n",
      @wt.tex('# % & _'),
      'WTeX#tex should escape all special characters in non-TeX paragraphs'
    )
    assert_equal(
      "\\textless{} \\textgreater{} \\textasciitilde{} \\textbar{} \\textasciicircum{}\n",
      @wt.tex('< > ^ | ~'),
      'WTeX#tex should escape all special characters in non-TeX paragraphs'
    )
  end

  def test_tex_skip_command
    assert_equal(
      "foo \\bar baz\n",
      @wt.tex("foo \\bar baz"),
      'WTeX#tex should skip TeX commands beginning with backslash'
    )
    assert_equal(
      "foo \\bar baz \\qux\n",
      @wt.tex("foo \\bar baz \\qux"),
      'WTeX#tex should skip TeX commands beginning with backslash'
    )
    assert_equal(
      "foo \\bar baz \\qux\n",
      @wt.tex("foo \\bar baz \\qux\n"),
      'WTeX#tex should skip TeX commands beginning with backslash'
    )
    assert_equal(
      "foo \\bar baz \\qux \\$\n",
      @wt.tex("foo \\bar baz \\qux \\$\n"),
      'WTeX#tex should skip TeX commands beginning with backslash'
    )
  end

  def test_tex_skip_text_math_mode
    assert_equal(
      "$\\backslash$\n",
      @wt.tex('$\backslash$'),
      'WTeX#tex should skip inside TeX math modes'
    )
    assert_equal(
      "$\\backslash$ foo $\\backslash$ bar\n",
      @wt.tex('$\backslash$ foo $\backslash$ bar'),
      'WTeX#tex should skip inside TeX math modes'
    )

    assert_equal(
      "$big\\$dollar$\n",
      @wt.tex('$big\\$dollar$'),
      'WTeX#tex should be aware of escaped dollar marks inside TeX math modes'
    )
    assert_equal(
      "$big\\$dollar \\$wow$\n",
      @wt.tex('$big\\$dollar \\$wow$'),
      'WTeX#tex should be aware of escaped dollar marks inside TeX math modes'
    )

    w = <<'_eos'
foo$
  sqrt{x} + sqrt{y}
$ bar
_eos
    assert_equal(
      w,
      @wt.tex(w),
      'WTeX#tex should be aware of TeX math modes in multiple lines'
    )
  end

  def test_tex_broken_text_math_mode
    assert_equal(
      "\\${}foo\n",
      @wt.tex('$foo'),
      'WTeX#tex should escape broken TeX math modes'
    )
  end

  def test_tex_escape_display_math_mode
    [
      "$$foo@baz$$\n",
      "foo $$foo@baz$$ $$qux@bar$$ foo\n",
      <<'_eos',
foo $$
  {$bar}
  {#baz\{%qux
$$ foo
_eos
    ].each {|w|
      assert_equal(
        w,
        @wt.tex(w),
        'WTeX#tex should skip inside TeX math modes'
      )
    }
  end

  def test_tex_skip_verb
    assert_equal(
      "\\verb|$%{|\n",
      @wt.tex('\verb|$%{|'),
      'WTeX#tex should skip inside verb commands'
    )
  end

  def test_tex_broken_verb
    assert_equal(
      "$\\backslash$verb\\textbar{}abc\n",
      @wt.tex('\verb|abc'),
      'WTeX#tex should escape broken verb commands'
    )
  end

  def test_tex_skip_curly_brackets
    assert_equal(
      "{$%#}\n",
      @wt.tex('{$%#}'),
      'WTeX#tex should skip inside curly brackets'
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
        'WTeX#tex should skip nested curly brackets'
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
        'WTeX#tex should be aware of escaped curly brackets'
      )
    }
  end

  def test_tex_skip_environment
    [
      "\\begin{itembox}foo$bar\\end{itembox}\n",
      "abc \\begin{itembox}foo$bar\\end{itembox} xyz\n",
#      "\\begin {itembox}foo$bar\\end   {itembox} xyz\n",
      "\\begin{itembox}foo\\begin{mmm}$bar\\end{mmm}\\end{itembox}\n",
      "\\begin{itembox}foo\\begin{mmm}$bar\\end{mmm}\\end{itembox} foo\n",
      <<'_eos',
\begin{itembox}
foo {
  {$bar}
  {#baz\\{%qux
}} foo
\end{itembox} bar
_eos
      <<'_eos',
\begin{itembox}
foo {
  \begin{itembox}
    {$bar}
  \end{itembox}
  {#baz\{%qux
}} foo \\end{itembox}
\end{itembox} bar
_eos
    ].each {|w|
      assert_equal(
        w,
        @wt.tex(w),
        'WTeX#tex should skip inside TeX environments'
      )
    }
  end

end
